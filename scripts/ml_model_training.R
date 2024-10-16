# ----------------------------------------------------------------------------------------
# Title:        ml_model_training.R
# Author:       Christoph Hartleb
# Date:         2024-10-02
# Description:  Machine learning pipeline for predicting movie ratings.
# Version:      1.4
#
# You are free to:
# - Share — copy and redistribute the material in any medium or format.
#
# Under the following terms:
# - Attribution — You must give appropriate credit, provide a link to the license, and 
#   indicate if changes were made. You may do so in any reasonable manner, but not in any 
#   way that suggests the licensor endorses you or your use.
# - NonCommercial — You may not use the material for commercial purposes.
# - NoDerivatives — If you remix, transform, or build upon the material, you may not 
#   distribute the modified material.
#
# No additional restrictions — You may not apply legal terms or technological measures 
# that legally restrict others from doing anything the license permits.
# ----------------------------------------------------------------------------------------

library(randomForest)
library(ggplot2)
library(dplyr)

# Notes:
# - readRDS(): Loads preprocessed datasets (train_data and test_data) from RDS files.
# - These datasets are the result of previous feature engineering.
train_data <- readRDS("data/preprocessed/train_data.rds")
test_data <- readRDS("data/preprocessed/test_data.rds")

# Notes:
# - colnames(): Retrieves and prints the column names of train_data for debugging purposes.
cat("Columns in train_data:", colnames(train_data), "\n")

# Notes:
# - all(): Checks if all elements in required_columns are present in train_data's column names.
# - %in%: Checks if each required column is in train_data.
# - stop(): Halts the code if any required column is missing, displaying an error message.
required_columns <- c("RatingYear", "RatingMonth", "UserAvgRating", "MovieAvgRating", "Rating", "Year")
if (!all(required_columns %in% colnames(train_data))) {
  stop("Missing required feature columns in train_data")
}

# Notes:
# - select(): Removes the MovieAvgRating column from train_data to ensure proper merging later.
# - everything(): Ensures the remaining columns are kept in the same order.
train_data <- train_data %>%
  select(-MovieAvgRating, everything())

# Notes:
# - group_by(): Groups the data by MovieID, so that summarise() operates on each group separately.
# - summarise(): Calculates the mean rating for each movie in the training data, ignoring missing values (na.rm = TRUE).
movie_avg_ratings <- train_data %>%
  group_by(MovieID) %>%
  summarise(MovieAvgRating = mean(Rating, na.rm = TRUE), .groups = 'drop')

# Notes:
# - merge(): Combines the train_data with the movie_avg_ratings data based on MovieID.
# - all.x = TRUE: Ensures all rows from train_data are kept, even if no corresponding row exists in movie_avg_ratings.
train_data <- merge(train_data, movie_avg_ratings, by = "MovieID", all.x = TRUE)

# Notes:
# - %in%: Checks if "MovieAvgRating" already exists in test_data's column names.
# - If not present, merge the movie_avg_ratings into test_data to include the average rating for each movie.
if (!"MovieAvgRating" %in% colnames(test_data)) {
  test_data <- merge(test_data, movie_avg_ratings, by = "MovieID", all.x = TRUE)
}

# Notes:
# - select(): Removes columns with suffixes ".x" or ".y", which indicate duplicate columns generated during merging.
# - ends_with(): Identifies columns that end with ".x" or ".y".
train_data <- train_data %>%
  select(-ends_with(".x"), -ends_with(".y"))

# Notes:
# - Same cleaning process as for train_data, applied to test_data to remove duplicate columns.
test_data <- test_data %>%
  select(-ends_with(".x"), -ends_with(".y"))

# Notes:
# - cat(): Prints the cleaned column names of train_data and test_data for debugging purposes.
cat("Cleaned Training Data Columns:", colnames(train_data), "\n")
cat("Cleaned Test Data Columns:", colnames(test_data), "\n")

# Notes:
# - select(): Removes irrelevant columns (Title, Genres, MovieID, UserID, Timestamp) from train_data_rf and test_data_rf.
# - These columns are not necessary for the Random Forest model and can be excluded.
train_data_rf <- train_data %>% select(-Title, -Genres, -MovieID, -UserID, -Timestamp)  # Exclude Timestamp
test_data_rf <- test_data %>% select(-Title, -Genres, -MovieID, -UserID, -Timestamp)  # Exclude Timestamp

# Notes:
# - intersect(): Finds the common columns between train_data_rf and test_data_rf.
# - Only the common columns are retained to ensure both datasets have consistent features.
common_columns <- intersect(colnames(train_data_rf), colnames(test_data_rf))

# Notes:
# - [, common_columns]: Subsets train_data_rf and test_data_rf to only include the columns in common_columns.
train_data_rf <- train_data_rf[, common_columns]
test_data_rf <- test_data_rf[, common_columns]

# Notes:
# - anyNA(): Checks if there are any missing values (NA) in train_data_rf or test_data_rf.
# - stop(): Halts execution if missing values are found, with an error message.
if (anyNA(train_data_rf) || anyNA(test_data_rf)) {
  stop("There are missing values in the training or test data.")
}

# Notes:
# - cat(): Prints the final set of columns after selecting relevant features for the model.
cat("Final Training Data Columns:", colnames(train_data_rf), "\n")
cat("Final Test Data Columns:", colnames(test_data_rf), "\n")

# Notes:
# - set.seed(): Ensures reproducibility of the Random Forest model by setting a fixed random seed.
# - randomForest(): Trains a Random Forest model using the training data (train_data_rf).
# - Rating ~ .: Specifies that Rating is the target variable, and all other columns are predictors.
# - ntree = 100: Specifies that the Random Forest model should use 100 decision trees.
# - importance = TRUE: Ensures the model calculates feature importance.
set.seed(123)  # For reproducibility
rf_model <- randomForest(Rating ~ ., data = train_data_rf, ntree = 100, importance = TRUE)

# Notes:
# - print(): Displays details about the trained Random Forest model, including error rates and feature importance.
print(rf_model)

# Notes:
# - predict(): Generates predictions on the test data (test_data_rf) using the trained Random Forest model.
rf_predictions <- predict(rf_model, newdata = test_data_rf)

# Notes:
# - mean(): Calculates the Mean Squared Error (MSE) between the actual and predicted ratings.
# - na.rm = TRUE: Ensures that missing values are ignored when calculating the MSE.
rf_mse <- mean((test_data$Rating - rf_predictions)^2, na.rm = TRUE)
cat("Mean Squared Error on test data (Random Forest):", rf_mse, "\n")

# Notes:
# - sqrt(): Calculates the Root Mean Squared Error (RMSE) by taking the square root of the MSE.
rf_rmse <- sqrt(rf_mse)
cat("Root Mean Squared Error on test data (Random Forest):", rf_rmse, "\n")

# Notes:
# - ggplot(): Creates a scatter plot comparing actual ratings vs predicted ratings.
# - geom_point(): Plots the points on the graph, each representing a rating pair (actual vs predicted).
# - geom_abline(): Adds a red diagonal line (slope = 1), indicating where the perfect predictions (Actual = Predicted) would lie.
# - theme_minimal(): Applies a minimalistic theme to the plot for a clean appearance.
ggplot(data.frame(Actual = test_data$Rating, Predicted = rf_predictions), aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.5) +
  geom_abline(slope = 1, intercept = 0, color = "red") +
  ggtitle("Random Forest: Predicted vs Actual Ratings") +
  xlab("Actual Ratings") +
  ylab("Predicted Ratings") +
  theme_minimal()

# Notes:
# - dir.exists(): Checks if the "model" directory already exists.
# - dir.create(): Creates the "model" directory if it does not exist, allowing the models to be saved in it.
if (!dir.exists("model")) {
  dir.create("model")
}

# Notes:
# - saveRDS(): Saves the trained Random Forest model (rf_model) to an RDS file for future use.
saveRDS(rf_model, file = "model/random_forest_model.rds")

# Notes:
# - cat(): Prints a message confirming that the model has been saved successfully.
cat("Models saved successfully.\n")

