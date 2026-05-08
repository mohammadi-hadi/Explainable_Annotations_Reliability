# Preprocessing Methodology - Chapter 06: Annotation Reliability

## Overview
This chapter investigates the reliability of LLM annotations for detecting online sexism, comparing LLM-generated labels against human annotations.

## Data Source
- **SemEval-2023 Task 10**: Explainable Detection of Online Sexism (EDOS) — https://codalab.lisn.upsaclay.fr/competitions/7124
- **SemEval-2023 Task 11**: Learning with Disagreements (LeWiDi) — https://le-wi-di.github.io/

Access to both datasets is via shared-task registration; please follow the access terms set by the organisers. See `03_raw_data/ethics_reference.md`.

## Preprocessing Pipeline

### 1. Data Loading
Raw annotation data from the SemEval-2023 shared tasks is loaded with pandas. Inputs are the per-task CSV/TSV files distributed by the organisers.

### 2. Annotation Processing
- Human annotations are extracted and cleaned.
- LLM annotations (from multiple models) are collected via API calls.
- Inter-annotator agreement metrics are calculated (Krippendorff's alpha, Cohen's kappa).

### 3. Label Alignment
Labels are mapped to a common format for comparison:
- Sexist / Not Sexist (binary classification)
- Fine-grained categories when applicable

### 4. Data Splitting
- Standard train/validation/test splits following SemEval-2023 guidelines
- Stratified sampling to maintain class distribution

## Implementation Notes

### Integrated Analysis
The preprocessing for this chapter is tightly integrated with the analysis pipeline. Key operations are performed within the analysis notebooks and scripts in `06_analysis/`.

## Dependencies
```
pandas>=1.3.0
krippendorff>=0.4.0   # inter-annotator agreement
scikit-learn>=0.24.0
```

## Reproducibility
To reproduce the analysis:
1. Obtain the SemEval-2023 Task 10 and Task 11 data via the official task channels.
2. Follow the methodology described in `01_manuscript/paper.pdf`.
3. Analysis outputs and figures are documented in `05_processed_data/` and `06_analysis/reports/`.

## Ethics Note
This research uses publicly available datasets from SemEval-2023 shared tasks. All data handling follows the ethical guidelines established by the task organisers.
