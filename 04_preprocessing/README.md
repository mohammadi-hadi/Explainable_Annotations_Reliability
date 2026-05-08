# Preprocessing - Chapter 6

## Overview

This folder documents the preprocessing steps for the annotation reliability study using SemEval-2023 datasets.

## Data Sources

- **SemEval-2023 Task 10**: Explainable Detection of Online Sexism (EDOS)
- **SemEval-2023 Task 11**: Learning with Disagreements (LeWiDi)

## Preprocessing Steps

1. **Data Loading**
   - Loading shared task data files
   - Parsing annotation formats

2. **Annotation Processing**
   - Aggregating multiple annotator labels
   - Computing inter-annotator agreement metrics
   - Handling disagreements

3. **Feature Extraction**
   - Text preprocessing for model input
   - Explanation extraction and alignment

## Methodology

See `preprocessing_methodology.md` in this folder for the detailed pipeline. The published analysis is described in `01_manuscript/paper.pdf`.
