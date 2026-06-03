<div align="center">

# Benefits of Explainable NLP in the Annotation Process

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20091840.svg)](https://doi.org/10.5281/zenodo.20091840)
[![GeBNLP @ ACL 2025](https://img.shields.io/badge/GeBNLP%20%40%20ACL%202025-blue.svg)](https://doi.org/10.18653/v1/2025.gebnlp-1.9)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

*Comparing content-driven SHAP explanations with demographic persona-prompting for LLM annotation.*

</div>

## Paper

|                  |                                                                          |
| ---------------- | ------------------------------------------------------------------------ |
| **Title**        | Assessing the Reliability of LLM Annotations in the Context of Demographic Bias and Model Explanation |
| **Authors**      | Hadi Mohammadi, Tina Shahedi, Pablo Mosteiro, Massimo Poesio, Robert A. Bagheri, Anastasia Giachanou |
| **Affiliation**  | Utrecht University, The Netherlands |
| **Venue**        | Workshop on Gender Bias in Natural Language Processing (GeBNLP), ACL 2025, pp. 92--104 |
| **DOI (paper)**  | [10.18653/v1/2025.gebnlp-1.9](https://doi.org/10.18653/v1/2025.gebnlp-1.9) |
| **Code archive** | [10.5281/zenodo.20091840](https://doi.org/10.5281/zenodo.20091840) (this repository, snapshot v1.0-thesis) |

> *Hadi Mohammadi and Tina Shahedi contributed equally to this work.*

> This repository accompanies **Chapter 5** of the PhD thesis
> *Let Me Explain! Explainable NLP for Understanding Large Language Models* (Hadi Mohammadi, Utrecht University, 2026).

## Abstract

Annotation reliability shapes downstream NLP systems, but it is unclear how much of the disagreement in labels comes from annotator demographics versus from the content itself. This work compares human annotators of varied demographics against demographically persona-prompted LLMs, using SHAP to attribute label decisions to specific text spans. Across the studied tasks, content-driven explanations dominated demographic effects: text content was the primary driver of labels, and content-aware SHAP guidance was more effective for steering LLM annotators than persona prompting.

## Citation

If you use this code or data, please cite **both** the paper and this code archive:

```bibtex
@inproceedings{mohammadi2025explainable,
  title         = {Assessing the Reliability of LLM Annotations in the Context of Demographic Bias and Model Explanation},
  author        = {Mohammadi, Hadi and Shahedi, Tina and Mosteiro, Pablo and Poesio, Massimo and Bagheri, Robert A. and Giachanou, Anastasia},
  year          = {2025},
  booktitle     = {Workshop on Gender Bias in Natural Language Processing (GeBNLP), ACL 2025},
  doi           = {10.18653/v1/2025.gebnlp-1.9}
}

@software{mohammadi_explainable_annotations_reliability_2026,
  author    = {Mohammadi, Hadi and Shahedi, Tina and Mosteiro, Pablo and Poesio, Massimo and Bagheri, Robert A. and Giachanou, Anastasia},
  title     = {Benefits of Explainable NLP in the Annotation Process},
  year      = {2026},
  publisher = {Zenodo},
  version   = {v1.0-thesis},
  doi       = {10.5281/zenodo.20091840},
  url       = {https://doi.org/10.5281/zenodo.20091840}
}
```

---

## Overview

This repository accompanies the GeBNLP 2025 paper on assessing the reliability of LLM annotations under demographic bias. Using the EXIST 2024 sexism-detection dataset (English and Spanish tweets), it quantifies how annotator demographics relate to labelling with a Generalized Linear Mixed Model, compares LLM-generated annotations with human annotations under several persona-prompting scenarios, and uses SHAP to attribute label decisions to specific text spans.

![Model Structure](06_analysis/reports/figures/model.jpg)

## Key Contributions

- A Generalized Linear Mixed Model quantifying how annotator demographics relate to sexism labels (demographics explain ~8% of the variance; tweet content dominates)
- Analysis of LLM annotation reliability compared to human annotators
- Investigation of demographic bias in annotation tasks
- Framework for assessing model explanations in annotation contexts
- Evaluation on the EXIST 2024 sexism-detection dataset (English and Spanish)

## Repository Structure

```
Explainable_Annotations_Reliability/
├── README.md
├── LICENSE
├── CITATION.cff
├── 03_raw_data/
│   └── ethics_reference.md             # Data sources and ethics
├── 04_preprocessing/
│   ├── README.md
│   └── preprocessing_methodology.md    # Preprocessing pipeline
├── 05_processed_data/
│   └── README.md                       # Output data documentation
└── 06_analysis/
    ├── prompts.py                      # GenAI / GenP / GenXAI / GenPXAI prompt templates
    ├── run_annotation_scenarios.py     # SHAP-guided, persona-prompted annotation runner
    ├── requirements.txt                # Python dependencies
    ├── statistical_models/             # R mixed-effects analysis (GLMM) + agreement tests
    │   ├── README.md
    │   ├── glmm_demographic_effects_bilingual.R   # primary GLMM (EN+ES)
    │   ├── glmm_demographic_effects_english.R     # English GLMM + Fleiss' kappa
    │   ├── glmm_demographic_effects_spanish.R     # Spanish GLMM
    │   ├── agreement_demographic_tests.R          # chi-square / Fisher tests
    │   ├── R_requirements.txt
    │   └── data/
    │       └── demographic_combinations.csv       # 56 demographic combinations (aggregate)
    └── reports/
        └── figures/
            ├── model.jpg               # Architecture figure
            └── model.pdf
```

## Data Sources

This study uses the **EXIST 2024** shared-task dataset (Plaza et al., 2024): 6,920 English and Spanish tweets, each annotated by six individuals who reported their demographics.

- **EXIST 2024**: sEXism Identification in Social neTworks — https://nlp.uned.es/exist2024/

The data is sourced from Twitter/X and is license-restricted, so tweet-level data is not redistributed here; only the aggregate demographic-combinations table is included. See `03_raw_data/ethics_reference.md` for access terms and ethics documentation.

## License

MIT License — see [LICENSE](LICENSE).

## Contact

- **Hadi Mohammadi** — Utrecht University
- Website: [mohammadi.cv](https://mohammadi.cv)
