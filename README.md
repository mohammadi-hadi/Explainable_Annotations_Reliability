<div align="center">

# Explainable Annotations Reliability

### Assessing the Reliability of LLM Annotations in the Context of Demographic Bias

[![GeBNLP @ ACL 2025](https://img.shields.io/badge/GeBNLP%40ACL-2025-green.svg)](https://aclanthology.org/2025.gebnlp-1.9/)
[![arXiv](https://img.shields.io/badge/arXiv-2507.13138-b31b1b.svg)](https://arxiv.org/abs/2507.13138)
[![DOI](https://img.shields.io/badge/DOI-10.18653%2Fv1%2F2025.gebnlp--1.9-blue.svg)](https://doi.org/10.18653/v1/2025.gebnlp-1.9)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)

*Investigating LLM annotation reliability in the context of demographic bias and model explanation*

[Paper](https://aclanthology.org/2025.gebnlp-1.9/) • [arXiv](https://arxiv.org/abs/2507.13138) • [Website](https://mohammadi.cv)

---

</div>

## Paper

| | |
|---|---|
| **Title** | Assessing the Reliability of LLMs Annotations in the Context of Demographic Bias and Model Explanation |
| **Authors** | Hadi Mohammadi, Tina Shahedi, Pablo Mosteiro, Massimo Poesio, Ayoub Bagheri, Anastasia Giachanou |
| **Affiliation** | Utrecht University, Queen Mary University of London |
| **Venue** | GeBNLP 2025 (6th Workshop on Gender Bias in NLP) |
| **DOI** | [10.18653/v1/2025.gebnlp-1.9](https://doi.org/10.18653/v1/2025.gebnlp-1.9) |
| **URL** | [ACL Anthology](https://aclanthology.org/2025.gebnlp-1.9/) |

## Overview

This repository contains the code and materials for our research on assessing annotator reliability in the context of model predictions and explanations. We investigate how LLM-generated annotations compare to human annotations, particularly in the presence of demographic bias.

![Model Structure](https://github.com/hadimh93/Explainable_Annotations_Reliability/blob/main/reports/figures/model.jpg?raw=true)

## Key Contributions

- Analysis of LLM annotation reliability compared to human annotators
- Investigation of demographic bias in annotation tasks
- Framework for assessing model explanations in annotation contexts
- Evaluation using SemEval-2023 Task 10 and 11 datasets

## Repository Structure

```
Explainable_Annotations_Reliability/
├── README.md               # This file
├── LICENSE                 # MIT License
├── docs/                   # Documentation and methodology
│   └── bibliography.bib    # Bibliographic references
├── data/                   # Datasets (SemEval-2023 Task 10/11)
├── src/                    # Python source code
├── notebooks/              # Jupyter notebooks for analysis
└── reports/                # Project reports and figures
    └── figures/            # Visualizations
```

## Quick Start

```bash
# Clone the repository
git clone https://github.com/mohammadi-hadi/Explainable_Annotations_Reliability.git
cd Explainable_Annotations_Reliability

# Install dependencies
pip install -r requirements.txt

# Run analysis notebooks
jupyter notebook notebooks/
```

## Citation

```bibtex
@inproceedings{mohammadi2025assessing,
  title={Assessing the Reliability of LLMs Annotations in the Context of Demographic Bias and Model Explanation},
  author={Mohammadi, Hadi and Shahedi, Tina and Mosteiro, Pablo and Poesio, Massimo and Bagheri, Ayoub and Giachanou, Anastasia},
  booktitle={Proceedings of the 6th Workshop on Gender Bias in Natural Language Processing (GeBNLP)},
  year={2025},
  publisher={Association for Computational Linguistics},
  doi={10.18653/v1/2025.gebnlp-1.9},
  url={https://aclanthology.org/2025.gebnlp-1.9/}
}
```

## Related Work

This research is part of the PhD thesis "From Tokens to Thoughts: Explainable NLP for Understanding Large Language Models" by Hadi Mohammadi at Utrecht University (2025).

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contact

- **Hadi Mohammadi** - Utrecht University
- Email: [h.mohammadi@uu.nl](mailto:h.mohammadi@uu.nl)
- Website: [mohammadi.cv](https://mohammadi.cv)
