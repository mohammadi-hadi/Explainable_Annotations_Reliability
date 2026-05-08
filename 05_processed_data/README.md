# Chapter 6: Processed Data

## Annotation Reliability in Subjective NLP Tasks

This folder documents the processed data outputs from the annotation reliability analysis.

### Data Generation

Processed data is generated dynamically by running the analysis pipeline on SemEval-2023 raw data.
The analysis produces intermediate and final processed datasets stored in memory during execution.

### Pipeline Overview

To reproduce the processed data:
1. Install Python dependencies: `pip install -r 06_analysis/requirements.txt`
2. Follow the preprocessing pipeline described in `04_preprocessing/preprocessing_methodology.md`.
3. Apply the analysis described in `01_manuscript/paper.pdf`.

### Output Locations

Architecture and results figures are in `06_analysis/reports/figures/`.

### Data Source

Analysis is performed on SemEval-2023 Task 10 (EDOS) and Task 11 (LeWiDi) data.
See `03_raw_data/ethics_reference.md` for data access and usage terms.

### Note on Data Storage

Due to licensing restrictions on the original SemEval-2023 data, processed intermediate
datasets are not included in this archive. Researchers with access to the original data
can reproduce them by following the pipeline described above and in the published paper.
