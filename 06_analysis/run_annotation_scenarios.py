#!/usr/bin/env python3
"""
SHAP-guided, persona-prompted LLM annotation of sexism -- the four scenarios
evaluated in Chapter 5.

Given a fine-tuned sexism classifier, this module:
  1. computes per-token SHAP importance (SI_t) and importance ratios (IR_t),
     keeping the top tokens up to 95% cumulative importance;
  2. asks an LLM to label each text under four scenarios:
       GenAI    - plain instruction
       GenP     - + a demographic persona
       GenXAI   - + the SHAP-important tokens highlighted in **bold**
       GenPXAI  - persona + highlighted tokens
  3. compares the LLM labels against the human ground-truth labels.

Companion code for Chapter 5 of the PhD thesis
"Let Me Explain! Explainable NLP for Understanding Large Language Models".
The prompt templates are also in 06_analysis/prompts.py.

Set OPENAI_API_KEY before running. The SemEval-2023 EDOS / LeWiDi data is
license-restricted -- see 03_raw_data/ethics_reference.md for access terms.
"""
import os
import re
import random
from collections import defaultdict

import numpy as np
import torch
import torch.nn.functional as F
import shap
from nltk.corpus import stopwords
from sklearn.metrics import classification_report
from transformers import TextClassificationPipeline
import openai

openai.api_key = os.getenv("OPENAI_API_KEY")

SEED = 42
random.seed(SEED)
MAX_LEN = 256
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Demographic personas derived from the EDOS annotator demographics.
personas = {
    "Persona A": "You are a female aged 18-22, of White or Caucasian ethnicity, "
                 "with a Bachelor's degree, living in Europe.",
    "Persona B": "You are a male aged 23-45, of Hispanic or Latino ethnicity, "
                 "with a Master's degree, living in the Americas.",
    "Persona C": "You are a female aged 46+, of Black or African American ethnicity, "
                 "with a high school degree, living in Africa.",
}


def bold_important_tokens(text, important_tokens_set):
    """Wrap each SHAP-important token in **bold** for the XAI scenarios."""
    out = []
    for word in text.split():
        clean = re.sub(r"[^\w\s]", "", word).lower()
        out.append(f"**{word}**" if clean in important_tokens_set else word)
    return " ".join(out)


def compute_shap_values(model, tokenizer, texts, class_idx, lang):
    """Per-token SHAP importance SI_t and importance ratios IR_t for one class.

    SI_t is the mean absolute SHAP value per token (after 3-sigma outlier
    removal); IR_t normalises SI_t to sum to 1. Tokens are returned ranked by
    importance, with the running cumulative importance.
    """
    pipeline = TextClassificationPipeline(
        model=model.bert,
        tokenizer=tokenizer,
        device=device.index if device.type == "cuda" else -1,
        return_all_scores=True,
    )
    explainer = shap.Explainer(pipeline, masker=shap.maskers.Text(tokenizer))
    shap_values = explainer(texts)

    token_shap_values = defaultdict(list)
    for i in range(len(texts)):
        for token, value in zip(shap_values.data[i], shap_values.values[i][:, class_idx]):
            token_shap_values[token.lower()].append(value)

    nltk_lang_map = {"en": "english", "es": "spanish"}
    stop_words = set(stopwords.words(nltk_lang_map[lang]))
    token_shap_values = {t: v for t, v in token_shap_values.items()
                         if t not in stop_words and t.isalpha()}

    token_SI_t = {}
    for token, values in token_shap_values.items():
        values = np.array(values)
        mu, sigma = np.mean(values), np.std(values)
        kept = values[(values >= mu - 3 * sigma) & (values <= mu + 3 * sigma)]
        token_SI_t[token] = np.mean(np.abs(kept))

    total = sum(token_SI_t.values())
    token_IR_t = {t: si / total for t, si in token_SI_t.items()}
    sorted_tokens = sorted(token_IR_t.items(), key=lambda x: x[1], reverse=True)

    cumulative, cumulative_importances, tokens_list = 0.0, [], []
    for token, ir in sorted_tokens:
        cumulative += ir
        cumulative_importances.append(cumulative)
        tokens_list.append(token)
    return tokens_list, token_SI_t, token_IR_t, cumulative_importances


def select_top_tokens(tokens_list, token_IR_t, threshold=0.95):
    """Top tokens up to `threshold` cumulative importance."""
    cumulative, selected = 0.0, []
    for token in tokens_list:
        cumulative += token_IR_t[token]
        selected.append(token)
        if cumulative >= threshold:
            break
    return set(selected)


SCENARIO_NAMES = {2: "GenAI", 3: "GenP", 4: "GenXAI", 5: "GenPXAI"}


def generate_prompt(text, scenario, persona_description=None):
    """Build the instruction for one of the four annotation scenarios."""
    base = ("Read the text and answer if it is sexism or not. Answer with 'yes', "
            "'no', or 'neutral' and omit explanations.")
    persona = (f"Take the role of Persona: {persona_description} It is critical "
               f"that you answer the questions while staying true to the "
               f"characteristics and attributes of this role. ")
    focus = " The parts that are **bold** need more focus."
    if scenario == 2:        # GenAI
        return f"{base} Text: {text}"
    if scenario == 3:        # GenP
        return f"{persona}{base} Text: {text}"
    if scenario == 4:        # GenXAI
        return f"Read the text and answer if it is sexism or not.{focus} " \
               f"Answer with 'yes', 'no', or 'neutral' and omit explanations. Text: {text}"
    if scenario == 5:        # GenPXAI
        return f"{persona}Read the text and answer if it is sexism or not.{focus} " \
               f"Answer with 'yes', 'no', or 'neutral' and omit explanations. Text: {text}"
    return text


def get_genai_response(prompt, model="gpt-4o-mini", temperature=0.7):
    """Query the LLM for a single sexism label."""
    if not openai.api_key:
        raise SystemExit("Set the OPENAI_API_KEY environment variable before running.")
    response = openai.ChatCompletion.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        max_tokens=10,
        temperature=temperature,
    )
    return response["choices"][0]["message"]["content"].strip().lower()


def _to_label(response_text):
    if "yes" in response_text:
        return 1
    if "no" in response_text:
        return 0
    return -1  # neutral / unclear


def run_scenarios(val_df, important_tokens_set, text_col="tweet", label_col="label"):
    """Run the four scenarios over `val_df` and report accuracy for each."""
    results = {}
    for scenario in (2, 3, 4, 5):
        name = SCENARIO_NAMES[scenario]
        print(f"Processing scenario {scenario}: {name}")
        preds, truth = [], []
        for _, row in val_df.iterrows():
            text = row[text_col]
            if scenario in (4, 5):
                text = bold_important_tokens(text, important_tokens_set)
            persona_desc = None
            if scenario in (3, 5):
                # one demographic persona is assigned at random per instance
                _, persona_desc = random.choice(list(personas.items()))
            label = _to_label(get_genai_response(
                generate_prompt(text, scenario, persona_desc)))
            preds.append(label)
            truth.append(row[label_col])

        valid = [i for i, p in enumerate(preds) if p != -1]
        if not valid:
            print(f"  no valid responses for {name}")
            continue
        y_pred = [preds[i] for i in valid]
        y_true = [truth[i] for i in valid]
        acc = float(np.mean(np.array(y_pred) == np.array(y_true)))
        print(f"  accuracy ({name}): {acc:.3f}")
        print(classification_report(y_true, y_pred, target_names=["NO", "YES"]))
        results[name] = {"accuracy": acc, "n": len(valid)}
    return results


if __name__ == "__main__":
    # Expected flow (data + a fine-tuned classifier are provided by the user):
    #   1. load the EDOS/LeWiDi split into a DataFrame `val_df` with `tweet`/`label`
    #   2. load a fine-tuned sexism classifier `model` + `tokenizer`
    #   3. tokens, _, ir, _ = compute_shap_values(model, tokenizer, texts, class_idx=1, lang="en")
    #   4. important = select_top_tokens(tokens, ir, threshold=0.95)
    #   5. run_scenarios(val_df, important)
    raise SystemExit(__doc__)
