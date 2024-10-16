# ----------------------------------------------------------------------------------------
# Title:        ml_model_validation.R
# Author:       Christoph Hartleb
# Date:         2024-10-02
# Description:  Machine learning pipeline for validating movie rating predictions.
# Version:      1.3
# 
# © 2024 Christoph Hartleb. All rights reserved.
# 
# This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives
# 4.0 International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-nc-nd/4.0/
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
library(ggplot2)
library(stringr)
library(randomForest)

# Notes:
# - readRDS(): Reads a serialized R object from a file.
# - "model/random_forest_model.rds": Path to the saved Random Forest model.
# - random_forest_model: The variable to which the loaded Random Forest model is assigned.
random_forest_model <- readRDS("model/random_forest_model.rds")

# Notes:
# - readLines(): Reads each line of a text file into a character vector.
# - "data/final_holdout_test/ml-10M100K/movies.dat": Path to the movies dataset file.
# - strsplit(): Splits each line of the dataset based on a delimiter ("::").
# - do.call(rbind, ...): Combines the split lines into a matrix where each row is a movie.
# - as.data.frame(): Converts the matrix into a data frame.
# - stringsAsFactors = FALSE: Ensures that character columns are not converted to factors.
# - colnames(): Assigns column names to the data frame.
# - as.numeric(): Converts the MovieID column to numeric type.
test_movies_lines <- readLines("data/final_holdout_test/ml-10M100K/movies.dat")
test_movies <- do.call(rbind, strsplit(test_movies_lines, "::", fixed = TRUE))
test_movies <- as.data.frame(test_movies, stringsAsFactors = FALSE)
colnames(test_movies) <- c("MovieID", "Title", "Genres")
test_movies$MovieID <- as.numeric(test_movies$MovieID)

# Notes:
# - readLines(): Reads each line of a text file into a character vector.
# - "data/final_holdout_test/ml-10M100K/ratings.dat": Path to the ratings dataset file.
# - strsplit(): Splits each line of the dataset based on a delimiter ("::").
# - do.call(rbind, ...): Combines the split lines into a matrix where each row is a rating entry.
# - as.data.frame(): Converts the matrix into a data frame.
# - stringsAsFactors = FALSE: Ensures that character columns are not converted to factors.
# - colnames(): Assigns column names to the data frame.
# - as.numeric(): Converts the MovieID and UserID columns to numeric type.
test_ratings_lines <- readLines("data/final_holdout_test/ml-10M100K/ratings.dat")
test_ratings <- do.call(rbind, strsplit(test_ratings_lines, "::", fixed = TRUE))
test_ratings <- as.data.frame(test_ratings, stringsAsFactors = FALSE)
colnames(test_ratings) <- c("UserID", "MovieID", "Rating", "Timestamp")
test_ratings$MovieID <- as.numeric(test_ratings$MovieID)
test_ratings$UserID <- as.numeric(test_ratings$UserID)

# Notes:
# - read.csv(): Reads a CSV file into a data frame.
# - "data/preprocessed/ratings_cleaned.csv": Path to the cleaned ratings dataset file.
# - stringsAsFactors = FALSE: Ensures that character columns are not converted to factors.
cleaned_ratings <- read.csv("data/preprocessed/ratings_cleaned.csv", stringsAsFactors = FALSE)

# Notes:
# - all(): Checks if all elements of a vector are TRUE.
# - c("UserID", "MovieID", "Rating"): A vector of required column names.
# - %in%: Tests if elements are present in another vector.
# - colnames(): Retrieves the column names of a data frame.
# - !all(...): Negates the result of all(), triggering the condition if not all required columns are present.
# - stop(): Halts execution and displays an error message.
if (!all(c("UserID", "MovieID", "Rating") %in% colnames(cleaned_ratings))) {
  stop("Cleaned ratings data does not contain required columns.")
}

# Notes:
# - sub(): Performs a substitution based on a regular expression.
# - ".*\\((\\d{4})\\).*": A regular expression that extracts a 4-digit year enclosed in parentheses.
# - "\\1": The replacement pattern, representing the first captured group (the 4-digit year).
# - test_movies$Title: The column from which the year is extracted.
# - as.numeric(): Converts the extracted year to numeric format.
test_movies$Year <- as.numeric(sub(".*\\((\\d{4})\\).*", "\\1", test_movies$Title))

# Notes:
# - %>%: The pipe operator, used to chain operations in a readable format.
# - select(): Selects specific columns from a data frame.
# - MovieID, Year: The columns to retain from the test_movies data frame.
# - Removed Genres and Title: This comment notes that the 'Genres' and 'Title' columns were excluded.
test_movies <- test_movies %>%
  select(MovieID, Year)  # Removed Genres and Title

# Notes:
# - merge(): Combines two data frames by matching rows based on a common column (MovieID).
# - by = "MovieID": Specifies that the merge should be performed using the MovieID column.
# - all.x = TRUE: Keeps all rows from the first data frame (test_ratings), even if there is no match in the second.
test_data <- merge(test_ratings, test_movies, by = "MovieID", all.x = TRUE)

# Notes:
# - anyNA(): Checks if there are any NA (missing) values in the specified column.
# - stop(): Halts execution with an error message if any missing values are found.
if (anyNA(test_data$Timestamp)) {
  stop("There are missing values in the Timestamp column.")
}

# Notes:
# - as.POSIXct(): Converts numeric timestamps to POSIXct date-time format, using the specified origin date.
test_data$Timestamp <- as.POSIXct(as.numeric(test_data$Timestamp), origin = "1970-01-01")

# Notes:
# - as.POSIXlt(): Converts POSIXct to POSIXlt format to extract components like year and month.
# - $year: Gives the year minus 1900, so 1900 is added to adjust it to a full year.
# - $mon: Gives the month (0-11), so 1 is added to convert it to a conventional month (1-12).
test_data$RatingYear <- as.POSIXlt(test_data$Timestamp)$year + 1900
test_data$RatingMonth <- as.POSIXlt(test_data$Timestamp)$mon + 1

# Notes:
# - format(Sys.Date(), "%Y"): Retrieves the current year.
# - Calculate the difference between the current year and the year of the movie's release.
current_year <- as.numeric(format(Sys.Date(), "%Y"))
test_data$YearsSinceRelease <- current_year - test_data$Year

# Notes:
# - group_by(): Groups data by specified column (UserID) for summary calculations.
# - summarise(): Calculates summary statistics (mean of ratings) for each group.
# - na.rm = TRUE: Ensures missing values are ignored in calculations.
user_avg_ratings <- cleaned_ratings %>%
  group_by(UserID) %>%
  summarise(UserAvgRating = mean(Rating, na.rm = TRUE), .groups = 'drop')

# Notes:
# - Merges user average ratings with the test data using UserID as the key.
test_data <- merge(test_data, user_avg_ratings, by = "UserID", all.x = TRUE)

# Notes:
# - Placeholder for UserRatingCount: Initializes a column with zero values.
test_data$UserRatingCount <- 0  # Placeholder

# Notes:
# - weekdays(): Extracts the day of the week from the Timestamp.
test_data$DayOfWeek <- weekdays(test_data$Timestamp)

# Notes:
# - Checks if MovieAvgRating column exists in test_data; if not, calculates it.
if (!"MovieAvgRating" %in% colnames(test_data)) {
  movie_avg_ratings <- cleaned_ratings %>%
    group_by(MovieID) %>%
    summarise(MovieAvgRating = mean(Rating, na.rm = TRUE), .groups = 'drop')
  
  test_data <- merge(test_data, movie_avg_ratings, by = "MovieID", all.x = TRUE)
}

# Notes:
# - Selects relevant columns for further analysis.
required_columns <- c("UserID", "MovieID", "Year", "RatingYear", "RatingMonth", "YearsSinceRelease", "UserAvgRating", "UserRatingCount", "MovieAvgRating", "DayOfWeek")
test_data <- test_data %>% select(any_of(required_columns))

# Notes:
# - cat(): Outputs the column names of test_data for debugging.
cat("Test Data Columns for Prediction:", colnames(test_data), "\n")

# Notes:
# - Replaces NA values in MovieAvgRating with the mean of that column.
if (anyNA(test_data$MovieAvgRating)) {
  test_data$MovieAvgRating[is.na(test_data$MovieAvgRating)] <- mean(test_data$MovieAvgRating, na.rm = TRUE)
}
# Notes:
# - Replaces NA values in UserAvgRating with the mean of that column.
if (anyNA(test_data$UserAvgRating)) {
  test_data$UserAvgRating[is.na(test_data$UserAvgRating)] <- mean(test_data$UserAvgRating, na.rm = TRUE)
}

# Notes:
# - predict(): Makes predictions using the trained Random Forest model on the test data.
predictions <- predict(random_forest_model, newdata = test_data)

# Notes:
# - match(): Finds the corresponding actual ratings for the predictions by matching UserID and MovieID.
test_data$Rating <- as.numeric(cleaned_ratings$Rating[match(paste(test_ratings$UserID, test_ratings$MovieID), paste(cleaned_ratings$UserID, cleaned_ratings$MovieID))])

# Notes:
# - Imputes missing ratings with the mean rating from the cleaned_ratings data.
test_data$Rating[is.na(test_data$Rating)] <- mean(cleaned_ratings$Rating, na.rm = TRUE)

# Notes:
# - Checks for any NA values in either predictions or actual ratings and stops execution if found.
if (anyNA(test_data$Rating) || anyNA(predictions)) {
  stop("There are NA values in the predictions or actual ratings after imputation.")
}

#' Calculate Mean Squared Error (MSE)
#'
#' This function computes the Mean Squared Error (MSE) between the actual ratings
#' and the predicted ratings in the `test_data` data frame. The MSE is calculated
#' as the average of the squared differences between the actual and predicted ratings,
#' ignoring any missing values.
#'
#' @return A numeric value representing the Mean Squared Error (MSE) of the predictions.
get_mse <- function() {
  return(mean((test_data$Rating - predictions)^2, na.rm = TRUE))
}

#' Calculate Root Mean Squared Error (RMSE)
#'
#' This function calculates the Root Mean Squared Error (RMSE) by taking the square root
#' of the Mean Squared Error (MSE). RMSE is a commonly used metric for evaluating the
#' accuracy of predicted values, indicating how well the predictions match the actual
#' data. A lower RMSE value indicates better model performance.
#'
#' @return A numeric value representing the Root Mean Squared Error (RMSE) of the predictions.
get_rmse <- function() {
  return(sqrt(get_mse()))
}

# Print the RMSE
cat("Root Mean Squared Error on test data (Random Forest):", get_rmse(), "\n")

#' Create a Scatter Plot of Predicted vs Actual Ratings
#'
#' This function generates a scatter plot comparing the actual ratings to the predicted ratings.
#' It visualizes the relationship between the two sets of ratings, allowing users to assess
#' the performance of a prediction model. A diagonal reference line is included to indicate
#' perfect predictions, where actual ratings equal predicted ratings.
#'
#' @param actual A numeric vector of actual ratings.
#' @param predicted A numeric vector of predicted ratings.
#' @param plot_title A string representing the title of the plot (default is "Predicted vs Actual Ratings").
#' @return A ggplot object representing the scatter plot of actual vs predicted ratings.
plot_predicted_vs_actual <- function(actual, predicted, plot_title = "Predicted vs Actual Ratings") {
  plot_data <- data.frame(Actual = actual, Predicted = predicted)
  
  plot <- ggplot(plot_data, aes(x = Actual, y = Predicted)) +
    geom_point(alpha = 0.5) + 
    geom_abline(slope = 1, intercept = 0, color = "red") + 
    ggtitle(plot_title) + 
    xlab("Actual Ratings") + 
    ylab("Predicted Ratings") + 
    theme_minimal() 
  
  return(plot)
}

#' Save a ggplot Object to a File
#'
#' This function saves a ggplot object to a specified file format and location. It provides
#' flexibility in choosing the output file name, directory, dimensions, and resolution of the plot.
#' The function uses the `ggsave` function from the ggplot2 package to perform the save operation.
#'
#' @param plot A ggplot object to be saved.
#' @param filename A string representing the name of the file (with extension, e.g., "plot.png").
#' @param path A string representing the directory path where the file will be saved (default is the current working directory).
#' @param width A numeric value representing the width of the saved plot in inches (default is 10).
#' @param height A numeric value representing the height of the saved plot in inches (default is 7).
#' @param dpi A numeric value representing the resolution of the saved plot in dots per inch (default is 300).
#' @return NULL This function does not return a value; it performs a save operation and sends a message to confirm.
save_plot <- function(plot, filename, path = ".", width = 10, height = 7, dpi = 300) {
  full_path <- file.path(path, filename)
  ggsave(filename = full_path, plot = plot, width = width, height = height, dpi = dpi)
  message(paste("Plot saved to:", full_path))  # Confirmation message
}

# Example of saving the plot.
plot <- plot_predicted_vs_actual(test_data$Rating, predictions)
save_plot(plot, "model/predicted_vs_actual_ratings.png")

