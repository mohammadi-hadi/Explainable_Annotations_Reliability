# Statistical analysis — demographic effects on sexism annotation

R scripts for the statistical analysis reported in **Chapter 5 / the GeBNLP 2025
paper** ("Assessing the Reliability of LLM Annotations in the Context of Demographic
Bias and Model Explanation"). They quantify how annotator demographics relate to
sexism labels on the **EXIST 2024** dataset, using a Generalized Linear Mixed Model
(GLMM) and tests of association between annotator agreement and demographics.

## Contents

| File | What it does |
| --- | --- |
| `glmm_demographic_effects_bilingual.R` | **Primary model.** Flat logistic regression vs. mixed-effects logistic regression on the bilingual (EN+ES) data, with crossed/nested random effects. Reports variance components, ICC, AIC/BIC, likelihood-ratio test, confusion matrices, ROC/AUC. |
| `glmm_demographic_effects_english.R` | English subset: Fleiss' kappa for inter-annotator agreement, plus a per-tweet random-intercept GLMM and its ICC. |
| `glmm_demographic_effects_spanish.R` | Spanish subset: per-tweet random-intercept GLMM. |
| `agreement_demographic_tests.R` | Chi-square / Fisher tests of tweet-level agreement against the majority age, study level, country, and ethnicity of annotators. |
| `R_requirements.txt` | R packages required. |
| `data/demographic_combinations.csv` | The 56 unique annotator demographic combinations used in the model (aggregate counts only; matches the chapter's appendix table). |

## The model

The primary mixed-effects logistic regression is, in R notation:

```
label ~ gender + age + ethnicity + study_level + region
        + (1 | lang/id_EXIST) + (1 | annotator)        # family = binomial(logit)
```

- **Fixed effects** — annotator demographics: gender, age, ethnicity, study level, region.
- **Random effects** — tweets nested within language `(1 | lang/id_EXIST)` and annotators
  `(1 | annotator)` (crossed), since each tweet is labelled by several annotators and each
  annotator labels many tweets.
- Observations are weighted by inverse demographic/label frequency to correct for imbalance.

## Results these scripts reproduce (from the chapter)

- Demographic variables explain **~8 %** of the variance in labelling; tweet content dominates.
- **ICC ≈ 92.3 %**; random-effect variances: tweet **33.72**, annotator **5.54**, language **0.30**.
- Mixed model vs. flat baseline: accuracy **73.73 %** vs. 48.76 %, F1 **75.77 %** vs. 45.09 %;
  lower AIC/BIC and higher AUC for the mixed model.
- Odds ratios (reference = male, 18–22, White, Bachelor, Europe): Black **5.50**, Latino **0.46**,
  high-school education **0.63**, Africa **0.06**; English tweets **0.84** vs. Spanish **1.95**.
- Agreement tests: ethnicity is associated with agreement (p ≈ 0.012); study level is not
  (p ≈ 0.623); region is borderline (p ≈ 0.065).

## Data

The EXIST 2024 challenge data (Plaza et al., 2024, <https://nlp.uned.es/exist2024/>) is sourced
from Twitter/X and is **license-restricted**, so the per-tweet and weighted modelling files are
**not** redistributed here. To run the scripts, obtain the data through the shared task and place
the weighted files under `data/` (`total_data_weighted.csv`, `clean_en_data_weighted.csv`,
`clean_es_data_weighted.csv`, `exist2024_per_tweet.csv`). Only the aggregate
`data/demographic_combinations.csv` (counts, no tweet text) is included.

`set.seed(123)` is used in every script solely to make the stratified train/test split
reproducible — it does not generate any data or results.
