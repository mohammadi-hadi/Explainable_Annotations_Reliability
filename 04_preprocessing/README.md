# Preprocessing - Chapter 5

## Overview

This folder documents the preprocessing steps for the annotation reliability study using the EXIST 2024 dataset.

## Data Source

- **EXIST 2024**: sexism detection in tweets, English and Spanish — https://nlp.uned.es/exist2024/

## Preprocessing Steps

1. **Data Loading**
   - Loading the EXIST 2024 tweet and annotation files
   - Parsing the per-annotator demographic information

2. **Annotation Processing**
   - Aggregating the six annotator labels per tweet
   - Computing inter-annotator agreement (Fleiss' kappa)
   - Handling disagreements

3. **Demographic Processing**
   - Grouping the 45 countries into five regions (Europe, America, Africa, Asia, Middle East)
   - Removing rare demographic groups (< 2% of annotators)
   - Inverse-frequency weighting to correct demographic and label imbalance

## Methodology

See `preprocessing_methodology.md` in this folder for the detailed pipeline. The full analysis is described in the published paper (citation in the main README).
