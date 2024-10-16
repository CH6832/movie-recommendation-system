# ----------------------------------------------------------------------------------------
# Title:        feature_engineering.R
# Author:       Christoph Hartleb
# Date:         2024-10-02
# Description:  Feature engineering for movie ratings prediction pipeline.
# Version:      1.1
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

library(dplyr)
library(tidyr)
library(caret)

# Load the preprocessed datasets.
movies <- read.csv("data/preprocessed/movies_cleaned.csv", stringsAsFactors = FALSE)
ratings <- read.csv("data/preprocessed/ratings_cleaned.csv", stringsAsFactors = FALSE)

# Merge Movies and Ratings Data
# Notes:
# - merge(): Combines the ratings and movies datasets by matching the MovieID column in both datasets.
# - This creates a new data frame containing both movie and rating data.
movie_ratings <- merge(ratings, movies, by = "MovieID")
cat("- Merged `movies_cleaned.csv` and `ratings_cleaned.csv` based on `MovieID`.\n")

# Notes:
# - The Year column from the movies dataset is used directly.
# - The check ensures that the Year column exists in the merged movie_ratings data.
# - If the column is missing, the script stops and raises an error.
if("Year" %in% colnames(movie_ratings)) {
  movie_ratings$Year <- movie_ratings$Year # Directly use the Year column from the movies data.
  cat("- `Year` directly taken from the movies dataset (new feature).\n")
} else {
  stop("Year column is missing in the movies dataset.")
}

# Notes:
# - POSIXlt() and POSIXct(): Convert the Timestamp column from Unix time to a human-readable date-time format.
# - $year and $mon: Extract the year and month from the Timestamp.
# - `RatingYear` and `RatingMonth` are new features created by extracting the year and month from the Timestamp.
movie_ratings$RatingYear <- as.POSIXlt(as.POSIXct(movie_ratings$Timestamp, origin="1970-01-01"))$year + 1900
movie_ratings$RatingMonth <- as.POSIXlt(as.POSIXct(movie_ratings$Timestamp, origin="1970-01-01"))$mon + 1
cat("- `RatingYear` and `RatingMonth` extracted from the `Timestamp` (new features).\n")

# Notes:
# - sum(is.na()): Calculates the total number of missing (NA) values in the movie_ratings dataset after feature engineering.
# - This is used to check data quality after new features are added.
missing_values <- sum(is.na(movie_ratings))
cat("- Number of missing values after feature engineering:", missing_values, "\n")

# Notes:
# - set.seed(): Ensures reproducibility by setting a random seed before splitting the data.
# - createDataPartition(): Splits the data into training and test sets.
#   - p = 0.8: 80% of the data will be used for training, and 20% for testing.
#   - list = FALSE: Ensures that the function returns a matrix of row indices, not a list.
set.seed(123)  # For reproducibility
trainIndex <- createDataPartition(movie_ratings$Rating, p = 0.8, list = FALSE)
train_data <- movie_ratings[trainIndex, ]  # Training data (80%)
test_data <- movie_ratings[-trainIndex, ]  # Test data (20%)

# Notes:
# - cat(): Prints the sizes of the training and test datasets for debugging and verification.
cat("\n## Train-Test Split Overview\n")
cat("- Training data size:", nrow(train_data), "rows\n")
cat("- Test data size:", nrow(test_data), "rows\n")

# Notes:
# - as.numeric(): Converts the Timestamp column to a numeric format, representing the number of seconds since 1970 (Unix time).
# - POSIXct(): Ensures that the Timestamp is in date-time format before conversion to numeric.
train_data$Timestamp <- as.numeric(as.POSIXct(train_data$Timestamp))
test_data$Timestamp <- as.numeric(as.POSIXct(test_data$Timestamp))

# Notes:
# - dir.exists(): Checks if the directory "data/processed" exists.
# - dir.create(): Creates the "data/processed" directory if it doesn't exist to store the processed data.
if (!dir.exists("data/processed")) {
  dir.create("data/processed")
}

# Notes:
# - saveRDS(): Saves the train_data and test_data as RDS files for later use in modeling.
saveRDS(train_data, file = "data/preprocessed/train_data.rds")
saveRDS(test_data, file = "data/preprocessed/test_data.rds")

# Notes:
# - cat(): Prints a message confirming that the feature engineering process and data saving have been completed successfully.
cat("Feature engineering completed. Processed data saved.\n")
