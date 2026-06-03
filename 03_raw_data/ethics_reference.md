# Data Ethics Reference - Chapter 5

## Data Source

### EXIST 2024: sEXism Identification in Social neTworks
- **Provider**: EXIST 2024 shared-task organizers (Plaza et al., 2024)
- **Task**: Sexism detection in tweets (we use Task 1, binary classification)
- **Content**: 6,920 training tweets in English and Spanish (3,260 English, 3,660 Spanish), sourced from Twitter/X
- **Annotators**: each tweet labelled by six annotators who reported demographic information (gender, age, ethnicity, education, country)
- **Access**: through shared-task registration
- **URL**: https://nlp.uned.es/exist2024/

## Ethics Considerations

- Data collected under the shared task's ethical guidelines
- Used for research purposes as permitted by the task terms
- Analysed at the aggregate level (e.g. demographic combinations)
- No individual user data or identifiable annotator information is retained

## Usage in This Study

This study uses the EXIST 2024 dataset to evaluate:
- how annotator demographics relate to labelling (a Generalized Linear Mixed Model)
- LLM annotation reliability compared to human annotators
- model explanation effectiveness (SHAP)

All usage complies with the original shared-task terms and conditions. Because the data is sourced from Twitter/X and is license-restricted, tweet-level data is not redistributed in this archive.
