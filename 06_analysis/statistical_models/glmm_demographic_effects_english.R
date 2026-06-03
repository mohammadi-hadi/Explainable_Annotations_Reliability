# =====================================================================
# Chapter 5 / GeBNLP 2025 -- Assessing the Reliability of LLM Annotations
# English subset: Fleiss' kappa (inter-annotator agreement) + a GLMM of
# demographic effects on sexism labels (EXIST 2024, English tweets).
#
#   label ~ gender + age + ethnicity + study_level + region + (1 | id_EXIST)
#   family = binomial
# Reports Fleiss' kappa for annotator agreement, the per-tweet random
# intercept, the ICC, and flat-vs-mixed classification metrics.
#
# Data note: EXIST 2024 (Plaza et al., 2024, https://nlp.uned.es/exist2024/)
# is license-restricted and NOT redistributed here. Place the weighted
# English file at data/clean_en_data_weighted.csv to run.
# set.seed(123) is used only for the stratified train/test split.
# =====================================================================

# Load necessary libraries
library(tidyverse)    # Utility functions for data manipulation
library(lme4)         # Mixed effects modeling
library(sjPlot)       # Visualization of model results
library(performance)  # For advanced model diagnostics
library(caret)        # For evaluation metrics
library(car)          # For residual diagnostics
library(pROC)         # For ROC curve analysis
library(forcats)      # For handling factor levels more robustly
library(irr)          # For Fleiss' Kappa calculation

# Load the dataset
data <- read.csv("data/clean_en_data_weighted.csv")

# Ensure proper formatting of variables
data <- data %>%
  mutate(
    label = factor(label, levels = c(0, 1), labels = c("NO", "YES")),  # Binary target variable
    gender = relevel(as.factor(gender), ref = "M"),                   # Reference level: Male
    age = relevel(as.factor(age), ref = "18-22"),                     # Reference level: Age 18-22
    ethnicity = relevel(as.factor(ethnicity), ref = "Black or African American"),  # Reference: Black
    study_level = relevel(as.factor(study_level), ref = "High school degree or equivalent"),  # Reference: High school
    region = relevel(as.factor(region), ref = "Africa"),              # Reference: Africa
    annotator = as.factor(annotator),                                 # Annotator ID
    id_EXIST = as.factor(id_EXIST)                                    # Tweet ID
  )

# Filter tweets with multiple annotations
multi_annotated_tweets <- data %>%
  group_by(id_EXIST) %>%
  filter(n_distinct(annotator) > 1) %>%
  ungroup()

# Reshape the data to wide format for Fleiss' Kappa calculation
wide_annotations <- multi_annotated_tweets %>%
  select(id_EXIST, annotator, label) %>%
  pivot_wider(names_from = annotator, values_from = label)

# Ensure all annotator columns are characters for consistency
wide_annotations <- wide_annotations %>%
  mutate(across(-id_EXIST, as.character))  # Convert all annotator columns to character type, excluding 'id_EXIST'

# Replace missing values (NA) with "NO" (or any consistent value) to avoid empty cells
wide_annotations[is.na(wide_annotations)] <- "NO"

# Remove rows that do not have enough annotations for Fleiss' Kappa
wide_annotations <- wide_annotations %>%
  filter(rowSums(!is.na(select(., -id_EXIST))) > 1)  # Keep rows with more than one valid annotation

# Create a matrix for Fleiss' Kappa calculation
annotation_matrix <- wide_annotations %>%
  select(-id_EXIST) %>%
  as.matrix()

# Verify that there are enough columns and rows for Fleiss' Kappa
if (ncol(annotation_matrix) < 2 || nrow(annotation_matrix) < 1) {
  stop("Error: Fleiss' Kappa requires at least two annotators and at least one item with multiple annotations.")
}

# Convert annotations to numeric values for Fleiss' Kappa calculation
annotation_matrix[annotation_matrix == "YES"] <- 1
annotation_matrix[annotation_matrix == "NO"] <- 0
annotation_matrix <- apply(annotation_matrix, 2, as.numeric)

# Calculate Fleiss' Kappa for annotator agreement
fleiss_kappa <- kappam.fleiss(annotation_matrix)
cat("\nFleiss' Kappa for Annotator Agreement:\n")
print(fleiss_kappa)

# Split the data into training and testing sets using stratified sampling
set.seed(123)  # For reproducibility
train_index <- createDataPartition(data$label, p = 0.8, list = FALSE)
train <- data[train_index, ]
test <- data[-train_index, ]

# Align factor levels in the training and test datasets to match the original dataset
factor_columns <- c("ethnicity", "gender", "age", "study_level", "region", "annotator", "id_EXIST")
for (col in factor_columns) {
  train[[col]] <- factor(train[[col]], levels = levels(data[[col]]))
  test[[col]] <- factor(test[[col]], levels = levels(data[[col]]))
}

# 1. Flat logistic regression model
flat_model <- glm(label ~ gender + age + ethnicity + study_level + region,
                  data = train,
                  weights = weight,  # Ensure "weight" column is correct
                  family = binomial(link = "logit"))

# Summarize the flat model
cat("\nFlat Model Summary:\n")
print(summary(flat_model))

# QQ Plot for deviance residuals of the flat model
residuals_deviance <- residuals(flat_model, type = "deviance")
qqPlot(residuals_deviance, main = "QQ Plot of Deviance Residuals", ylab = "Deviance Residuals")

# 2. Mixed-effects logistic regression model with id_EXIST as random effect
mixed_model_1 <- glmer(
  label ~ gender + age + ethnicity + study_level + region + (1 | id_EXIST),
  data = train,
  weights = weight,  # Ensure "weight" column is correct
  family = binomial(link = "logit"),
  control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 1e5))
)

# Summarize the mixed model 1
cat("\nMixed Model Summary:\n")
print(summary(mixed_model_1))

# Generate QQ Plot for random effects of the mixed model
random_effects_id <- ranef(mixed_model_1)$id_EXIST[[1]]
qqnorm(random_effects_id, main = "QQ Plot of Random Effects (id_EXIST)")
qqline(random_effects_id, col = "red")

# Calculate the Intraclass Correlation Coefficient (ICC) for mixed model 1 manually
variance_components <- VarCorr(mixed_model_1)

# Extract variance of the random effect (id_EXIST) and residual variance
id_exist_variance <- attr(variance_components$id_EXIST, "stddev")[1]^2
residual_variance <- pi^2 / 3  # For logistic mixed-effects models, residual variance is π^2 / 3

# Calculate ICC as the proportion of variance explained by the grouping structure
icc_value_1 <- id_exist_variance / (id_exist_variance + residual_variance)

cat("\nIntraclass Correlation Coefficient (ICC) for Mixed Model 1:\n")
print(icc_value_1)

# Visualize coefficients for flat and mixed models
plot_model(flat_model, show.values = TRUE, value.offset = 0.3, title = "Flat Model Coefficients")
plot_model(mixed_model_1, show.values = TRUE, value.offset = 0.3, title = "Mixed Model Coefficients")

# Random and fixed effects visualization
plot_model(mixed_model_1, type = "re", title = "Random Effects - Mixed Model 1")
plot_model(mixed_model_1, type = "est", show.values = TRUE, value.offset = 0.3, title = "Fixed Effects - Mixed Model 1")

# Predictions and evaluation
# Flat model predictions
test$flat_predicted <- predict(flat_model, newdata = test, type = "response")
test$flat_predicted_label <- ifelse(test$flat_predicted > 0.5, "YES", "NO")
conf_matrix_flat <- confusionMatrix(
  factor(test$flat_predicted_label, levels = c("NO", "YES")),
  factor(test$label, levels = c("NO", "YES"))
)
cat("\nConfusion Matrix for Flat Model:\n")
print(conf_matrix_flat)

# Mixed model predictions
test$mixed_predicted_1 <- predict(mixed_model_1, newdata = test, type = "response", allow.new.levels = TRUE)
test$mixed_predicted_label_1 <- ifelse(test$mixed_predicted_1 > 0.5, "YES", "NO")
conf_matrix_mixed_1 <- confusionMatrix(
  factor(test$mixed_predicted_label_1, levels = c("NO", "YES")),
  factor(test$label, levels = c("NO", "YES"))
)
cat("\nConfusion Matrix for Mixed Model:\n")
print(conf_matrix_mixed_1)

# Optional: Visualize ROC curves for flat and mixed models
roc_flat <- roc(test$label, test$flat_predicted, levels = c("NO", "YES"))
roc_mixed_1 <- roc(test$label, test$mixed_predicted_1, levels = c("NO", "YES"))

plot.roc(roc_flat, col = "#377eb8", main = "ROC Curve for Flat Model")
plot.roc(roc_mixed_1, col = "#4daf4a", add = TRUE)
legend("bottomright", legend = c("Flat Model", "Mixed Model"),
       col = c("#377eb8", "#4daf4a"), lty = 1)
