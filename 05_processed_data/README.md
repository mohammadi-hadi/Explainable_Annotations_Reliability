# Chapter 5: Processed Data

## Annotation Reliability in Subjective NLP Tasks

This folder documents the processed data outputs from the annotation reliability analysis.

### Data Generation

Processed data is generated dynamically by running the analysis pipeline on the EXIST 2024 data. The analysis produces intermediate and final datasets used during execution.

### Pipeline Overview

To reproduce the processed data:
1. Install dependencies: `pip install -r 06_analysis/requirements.txt` (and the R packages in `06_analysis/statistical_models/R_requirements.txt`).
2. Follow the preprocessing pipeline described in `04_preprocessing/preprocessing_methodology.md`.
3. Apply the analysis described in the published paper (citation in the main README).

### Output Locations

Architecture and results figures are in `06_analysis/reports/figures/`. The 56 unique annotator demographic combinations used by the mixed-effects model are in `06_analysis/statistical_models/data/demographic_combinations.csv`.

### Data Source

Analysis is performed on the EXIST 2024 dataset (https://nlp.uned.es/exist2024/). See `03_raw_data/ethics_reference.md` for data access and usage terms.

### Note on Data Storage

Because the EXIST 2024 data is sourced from Twitter/X and is license-restricted, processed
tweet-level datasets are not included in this archive. Researchers with access to the original
data can reproduce them by following the pipeline described above and in the published paper.
