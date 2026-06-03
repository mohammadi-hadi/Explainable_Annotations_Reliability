# =====================================================================
# Chapter 5 / GeBNLP 2025 -- Assessing the Reliability of LLM Annotations
# Spanish subset: GLMM of demographic effects on sexism labels
# (EXIST 2024, Spanish tweets).
#
#   label ~ gender + age + ethnicity + study_level + region + (1 | id_EXIST)
#   family = binomial
#
# Data note: EXIST 2024 (Plaza et al., 2024, https://nlp.uned.es/exist2024/)
# is license-restricted and NOT redistributed here. Place the weighted
# Spanish file at data/clean_es_data_weighted.csv to run.
# set.seed(123) is used only for the stratified train/test split.
# =====================================================================

# Load necessary libraries
library(tidyverse)    # Utility functions for data manipulation
library(lme4)         # Mixed effects modeling
library(sjPlot)       # Visualization of model results
library(sjstats)      # For intraclass-correlation coefficient
library(performance)  # For advanced model diagnostics
library(caret)        # For evaluation metrics
library(car)          # For residual diagnostics
library(pROC)         # For ROC curve analysis
library(forcats)      # For handling factor levels more robustly

# Load the dataset
data <- read.csv("data/clean_es_data_weighted.csv")

data <- data %>%
  mutate(
    label = factor(label, levels = c(0, 1), labels = c("NO", "YES")),
    gender = relevel(as.factor(gender), ref = "M"),  # Set 'male' as the reference level
    age = relevel(as.factor(age), ref = "18-22"),        # Set '18-22' as the reference level
    ethnicity = relevel(as.factor(ethnicity), ref = "White or Caucasian"),  # Set 'White or Caucasian' as the reference level
    study_level = relevel(as.factor(study_level), ref = "Bachelor’s degree"),  # Set 'Bachelor’s degree' as the reference level
    region = relevel(as.factor(region), ref = "Europe"),  # Set 'Europe' as the reference level
    annotator = as.factor(annotator),
    id_EXIST = as.factor(id_EXIST)
  )

# Factor columns definition moved above the loop
factor_columns <- c("ethnicity", "gender", "age", "study_level", "region", "annotator", "id_EXIST")

# Split the data into training and testing sets using stratified sampling
set.seed(123)  # For reproducibility
train_index <- createDataPartition(data$label, p = 0.8, list = FALSE)
train <- data[train_index, ]
test <- data[-train_index, ]

# Align factor levels in the training and test datasets to match the original dataset
for (col in factor_columns) {
  train[[col]] <- factor(train[[col]], levels = levels(data[[col]]))
  test[[col]] <- factor(test[[col]], levels = levels(data[[col]]))
}

# 1. Flat logistic regression model
flat_model <- glm(label ~ gender + age + ethnicity + study_level + region,
                  data = train,
                  weights = weight,  # Corrected to match column name
                  family = binomial(link = "logit"))

# Summarize the flat model
summary(flat_model)

# QQ Plot for deviance residuals of the flat model
residuals_deviance <- residuals(flat_model, type = "deviance")
qqPlot(residuals_deviance, main = "QQ Plot of Deviance Residuals", ylab = "Deviance Residuals")

# 2. Mixed-effects logistic regression model with id_EXIST as random effect
mixed_model <- glmer(
  label ~ gender + age + ethnicity + study_level + region + (1 | id_EXIST),
  data = train,
  weights = weight,  # Corrected to match column name
  family = binomial(link = "logit"),
  control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 1e5))
)

# Summarize the mixed model 1
summary(mixed_model)

# Generate QQ Plot for random effects of the mixed model manually
random_effects_id <- ranef(mixed_model)$id_EXIST[[1]]
qqnorm(random_effects_id, main = "QQ Plot of Random Effects (id_EXIST)")
qqline(random_effects_id, col = "red")

# Calculate the Intraclass Correlation Coefficient (ICC) for mixed model
icc_value_1 <- performance::icc(mixed_model)
print(icc_value_1)

# 3. Visualizations
# Coefficient plots for flat and mixed models
plot_model(flat_model, show.values = TRUE, value.offset = 0.3, title = "Flat Model Coefficients")
plot_model(mixed_model, show.values = TRUE, value.offset = 0.3, title = "Mixed Model Coefficients")

# Random and fixed effects of the mixed model
plot_model(mixed_model, type = "re", title = "Random Effects - Mixed Model")
plot_model(mixed_model, type = "est", show.values = TRUE, value.offset = 0.3, title = "Fixed Effects - Mixed Model")

# 4. Predictions and evaluation
# Flat model predictions
test$flat_predicted <- predict(flat_model, newdata = test, type = "response")
test$flat_predicted_label <- ifelse(test$flat_predicted > 0.5, "YES", "NO")
conf_matrix_flat <- confusionMatrix(
  factor(test$flat_predicted_label, levels = c("NO", "YES")),
  factor(test$label, levels = c("NO", "YES"))
)
print(conf_matrix_flat)

# Mixed model 1 predictions
test$mixed_predicted_1 <- predict(mixed_model, newdata = test, type = "response", allow.new.levels = TRUE)
test$mixed_predicted_label_1 <- ifelse(test$mixed_predicted_1 > 0.5, "YES", "NO")
conf_matrix_mixed_1 <- confusionMatrix(
  factor(test$mixed_predicted_label_1, levels = c("NO", "YES")),
  factor(test$label, levels = c("NO", "YES"))
)
print(conf_matrix_mixed_1)

# Optional: Visualize ROC curves for flat and mixed models
roc_flat <- roc(test$label, test$flat_predicted, levels = c("NO", "YES"))
roc_mixed_1 <- roc(test$label, test$mixed_predicted_1, levels = c("NO", "YES"))

plot.roc(roc_flat, col = "#377eb8", main = "ROC Curve for Flat Model")
plot.roc(roc_mixed_1, col = "#4daf4a", add = TRUE)
legend("bottomright", legend = c("Flat Model", "Mixed Model"),
       col = c("#377eb8", "#4daf4a"), lty = 1)
