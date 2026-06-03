# Preprocessing Methodology - Chapter 5: Annotation Reliability

## Overview
This chapter investigates the reliability of LLM annotations for detecting online sexism, comparing LLM-generated labels against human annotations, and quantifies how annotator demographics relate to labelling.

## Data Source
- **EXIST 2024**: sEXism Identification in Social neTworks (Plaza et al., 2024) — https://nlp.uned.es/exist2024/

The labelled training set contains 6,920 tweets in English and Spanish (3,260 English, 3,660 Spanish), each annotated by six individuals who also reported gender, age, ethnicity, education, and country. Access is via shared-task registration; please follow the organisers' terms. See `03_raw_data/ethics_reference.md`.

## Preprocessing Pipeline

### 1. Data Loading
The EXIST 2024 tweet and annotation files are loaded with pandas, including the per-annotator demographic fields.

### 2. Annotation Processing
- Human annotations are extracted and cleaned.
- LLM annotations (from multiple models) are collected via API calls.
- Inter-annotator agreement is computed (Fleiss' kappa).

### 3. Demographic Processing
- The 45 annotator countries are grouped into five regions: Europe, America, Africa, Asia, Middle East.
- Rare demographic groups (< 2% of annotators) and singleton combinations are removed, leaving 56 unique demographic combinations.
- Observations are weighted by inverse demographic/label frequency to correct for imbalance.

### 4. Label Alignment & Splitting
- Labels are mapped to a binary scheme (sexist / not sexist).
- Stratified train/test splits maintain the class distribution (`set.seed(123)` for reproducibility).

## Implementation Notes

### Integrated Analysis
Preprocessing is tightly integrated with the analysis pipeline. Key operations run within the scripts in `06_analysis/` — Python for the LLM/SHAP prompting scenarios, and R for the mixed-effects models in `06_analysis/statistical_models/`.

## Dependencies
```
pandas>=1.3.0
scikit-learn>=0.24.0
# R: lme4, lmerTest, performance, irr (see 06_analysis/statistical_models/R_requirements.txt)
```

## Reproducibility
To reproduce the analysis:
1. Obtain the EXIST 2024 data via the official task channel (https://nlp.uned.es/exist2024/).
2. Follow the methodology described in the published paper (citation in the main README).
3. Analysis outputs and figures are documented in `05_processed_data/` and `06_analysis/reports/`.

## Ethics Note
This research uses the EXIST 2024 shared-task dataset. All data handling follows the ethical guidelines established by the task organisers; tweet-level data is not redistributed.
