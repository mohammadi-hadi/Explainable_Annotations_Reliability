# =====================================================================
# Chapter 5 / GeBNLP 2025 -- Assessing the Reliability of LLM Annotations
# Tests of association between annotator agreement and the majority
# demographic profile of a tweet's annotators (EXIST 2024).
#
# Each tweet's "Level of Agreement" is cross-tabulated against the
# majority age group, level of study, country, and ethnicity of its
# annotators; a chi-square test of independence is used, falling back to
# Fisher's exact test when expected cell counts are small (< 5).
# These are the demographic-agreement tests discussed in the chapter
# (e.g. ethnicity is associated with agreement while study level is not).
#
# Data note: the per-tweet EXIST 2024 file (annotator demographic lists +
# cleaned tweet text) is license-restricted and NOT redistributed here.
# Place it at data/exist2024_per_tweet.csv to run. Expected columns
# include: age_annotators, ethnicities_annotators, study_levels_annotators,
# countries_annotators, labels_task1, Level.of.Agreement,
# Majority.Age.Group, Majority.Level.of.Study, Majority.Country,
# Majority.Ethnic, Hard.label.
# =====================================================================

library(tidyverse)
library(stringr)
library(forcats)

# Load the data
data <- read.csv("data/exist2024_per_tweet.csv")
# Replace '-' strings with actual NA values
data[data == "-"] <- NA

# The per-annotator characteristic columns are stored as Python-style
# list strings (e.g. "['White', 'Black']"); parse them into vectors.
data$age_annotators        <- str_replace_all(data$age_annotators,        c("\\[" = "", "\\]" = "", "'" = "")) %>% str_split(", ")
data$ethnicities_annotators <- str_replace_all(data$ethnicities_annotators, c("\\[" = "", "\\]" = "", "'" = "")) %>% str_split(", ")
data$study_levels_annotators <- str_replace_all(data$study_levels_annotators, c("\\[" = "", "\\]" = "", "'" = "")) %>% str_split(", ")
data$countries_annotators   <- str_replace_all(data$countries_annotators,   c("\\[" = "", "\\]" = "", "'" = "")) %>% str_split(", ")
data$labels_task1           <- str_replace_all(data$labels_task1,           c("\\[" = "", "\\]" = "", "'" = "")) %>% str_split(", ")

# ---------------------------------------------------------------------
# Helper: share of YES labels per characteristic category (computed from
# the data -- no values are hard-coded).
# ---------------------------------------------------------------------
calculate_normalized_distribution <- function(characteristics, labels) {
  flat_list <- unlist(characteristics)
  flat_labels <- unlist(labels)

  total_counts <- table(flat_list)
  yes_counts <- table(flat_list[flat_labels == "YES"])

  normalized_distribution <- yes_counts / total_counts
  normalized_distribution[is.na(normalized_distribution)] <- 0
  return(normalized_distribution)
}

# Helper: total and YES counts per characteristic category.
calculate_counts <- function(characteristics, labels) {
  flat_list <- unlist(characteristics)
  flat_labels <- unlist(labels)

  total_counts <- table(flat_list)
  yes_counts <- table(flat_list[flat_labels == "YES"])

  counts_df <- data.frame('Total Count' = as.integer(total_counts), 'Yes Count' = as.integer(yes_counts))
  counts_df[is.na(counts_df)] <- 0
  return(counts_df)
}

# Counts per characteristic
age_counts         <- calculate_counts(data$age_annotators, data$labels_task1)
ethnic_counts      <- calculate_counts(data$ethnicities_annotators, data$labels_task1)
study_level_counts <- calculate_counts(data$study_levels_annotators, data$labels_task1)
country_counts     <- calculate_counts(data$countries_annotators, data$labels_task1)

print(age_counts)
print(ethnic_counts)
print(study_level_counts)
print(country_counts)

# Normalized YES distributions per characteristic
age_distribution         <- calculate_normalized_distribution(data$age_annotators, data$labels_task1)
ethnic_distribution      <- calculate_normalized_distribution(data$ethnicities_annotators, data$labels_task1)
study_level_distribution <- calculate_normalized_distribution(data$study_levels_annotators, data$labels_task1)
country_distribution     <- calculate_normalized_distribution(data$countries_annotators, data$labels_task1)

# ---------------------------------------------------------------------
# Hypothesis tests: Level of Agreement vs. majority demographic profile.
# chi-square test, with Fisher's exact test when any expected count < 5.
# ---------------------------------------------------------------------
# Ensure there are no missing values in the relevant columns
data <- data %>% drop_na(Level.of.Agreement, Majority.Age.Group, Majority.Level.of.Study, Majority.Country, Majority.Ethnic)

# Hypothesis 1: Level of Agreement vs. Majority Age Group
contingency_table_age <- table(data$Level.of.Agreement, data$Majority.Age.Group)
if (any(contingency_table_age < 5)) {
  fisher_test_age <- fisher.test(contingency_table_age)
  print(fisher_test_age)
} else {
  chi2_stat_age <- chisq.test(contingency_table_age)
  print(chi2_stat_age)
}

# Hypothesis 2: Level of Agreement vs. Majority Level of Study
contingency_table_study <- table(data$Level.of.Agreement, data$Majority.Level.of.Study)
if (any(contingency_table_study < 5)) {
  fisher_test_study <- fisher.test(contingency_table_study)
  print(fisher_test_study)
} else {
  chi2_stat_study <- chisq.test(contingency_table_study)
  print(chi2_stat_study)
}

# Hypothesis 3: Level of Agreement vs. Majority Country
contingency_table_country <- table(data$Level.of.Agreement, data$Majority.Country)
if (any(contingency_table_country < 5)) {
  fisher_test_country <- fisher.test(contingency_table_country, simulate.p.value = TRUE)
  print(fisher_test_country)
} else {
  chi2_stat_country <- chisq.test(contingency_table_country)
  print(chi2_stat_country)
}

# Hypothesis 4: Level of Agreement vs. Majority Ethnicity
contingency_table_ethnicity <- table(data$Level.of.Agreement, data$Majority.Ethnic)
if (any(contingency_table_ethnicity < 5)) {
  fisher_test_ethnicity <- fisher.test(contingency_table_ethnicity, simulate.p.value = TRUE)
  print(fisher_test_ethnicity)
} else {
  chi2_stat_ethnicity <- chisq.test(contingency_table_ethnicity)
  print(chi2_stat_ethnicity)
}
