# ----------------------------------------------------------------------------------------
# Title:        data_preprocessing.R
# Author:       Christoph Hartleb
# Date:         2024-10-02
# Description:  The script performs essential data preprocessing tasks on raw
#               datasets to clean and structure the data for further analysis.
# Version:      1.0
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

# Load other scripts.
source("scripts/utils.R")

# Check if packages are installed.
check_pkg_status(c("dplyr","tidyr","stringr","caret","readr"))

library(dplyr)
library(tidyr)
library(stringr)
library(caret)
library(readr)

# Load the datasets to preocess.
raw_movies_dataset <- load_dataset("data/raw/ml-latest-small/movies.csv")
raw_ratings_dataset <- load_dataset("data/raw/ml-latest-small/ratings.csv")
raw_links_dataset <- load_dataset("data/raw/ml-latest-small/links.csv")
raw_tags_dataset <- load_dataset("data/raw/ml-latest-small/tags.csv")

#' Check for Missing Values in Dataset
#'
#' This function checks for missing values in the provided dataset and handles them
#' by removing rows that contain any missing data. It prints the count of missing
#' values for each column in the dataset.
#'
#' @param data A data frame or tibble to be checked for missing values.
#' @param dataset_name A string representing the name of the dataset, used for logging
#'                     purposes when displaying missing value information.
#' @return A data frame with all rows containing missing values removed.
check_missing_values <- function(data, dataset_name) {
  missing_info <- sapply(data, function(x) sum(is.na(x)))
  cat("\nMissing values in", dataset_name, ":\n")
  print(missing_info)
  if (any(missing_info > 0)) {
    cat("\nHandling missing values by removing rows with missing data.\n")
    data <- na.omit(data)
  }
  return(data)
}

#' Remove Duplicate Rows from Dataset
#'
#' This function identifies and removes duplicate rows from the provided dataset.
#' It logs the number of duplicate rows that were removed.
#'
#' @param data A data frame or tibble to be checked for missing values.
#' @param dataset_name A string representing the name of the dataset, used for logging
#'                     purposes when displaying missing value information.
#' @return A data frame with duplicates removed.
remove_duplicates <- function(data, dataset_name) {
  initial_rows <- nrow(data)
  data <- distinct(data)
  removed_rows <- initial_rows - nrow(data)
  cat("\nRemoved", removed_rows, "duplicate rows from", dataset_name, ".\n")
  return(data)
}

#' Preprocess the Movies Dataset
#'
#' This function preprocesses the movies dataset by cleaning the title, extracting the
#' year from the title, and splitting genres into a list format. It also ensures that
#' all critical fields are present and removes any outlier titles.
#'
#' @param data A data frame containing the raw movies dataset.
#' @return A cleaned data frame with properly formatted MovieID, Title, Year, and Genres.
preprocess_movies <- function(data) {
  cat("\nPreprocessing Movies Data...\n")
  
  # Ensure we correctly extract Year, clean up Title and split Genres.
  data <- data %>%
    mutate(
      Title = str_trim(title), # Ensure title is trimmed of whitespace
      Year = as.numeric(str_extract(title, "\\d{4}")), # Extract year correctly from title
      Genres = str_split(genres, "\\|") # Split genres into a list
    ) %>%
    select(MovieID = movieId, Title, Year, Genres) %>%  # Include Genres in the selection
    mutate(MovieID = as.numeric(MovieID))
  
  # Remove rows with NA values in critical fields.
  data <- na.omit(data)  # Remove any rows with NA in essential fields.
  
  # Check for any outliers in titles (e.g., long/short titles).
  data <- data %>%
    filter(nchar(Title) > 1) # Remove excessively short titles.
  
  cat("\nFinished preprocessing Movies data.\n")
  return(data)
}

#' Preprocess the Ratings Dataset
#'
#' This function preprocesses the ratings dataset by converting timestamps into a
#' date-time format and renaming columns for consistency. It ensures that the data
#' is structured correctly for further analysis.
#'
#' @param data A data frame containing the raw ratings dataset.
#' @return A cleaned data frame with properly formatted UserID, MovieID, Rating, and Timestamp.
preprocess_ratings <- function(data) {
  cat("\nPreprocessing Ratings Data...\n")
  
  # Convert timestamp to date-time format
  data <- data %>%
    mutate(Timestamp = as.POSIXct(timestamp, origin = "1970-01-01")) %>%
    select(UserID = userId, MovieID = movieId, Rating = rating, Timestamp)
  
  cat("\nFinished preprocessing Ratings data.\n")
  return(data)
}

#' Preprocess the Tags Dataset
#'
#' This function preprocesses the tags dataset by converting timestamps into a
#' date-time format and renaming columns for clarity. The processed dataset is
#' prepared for subsequent analysis.
#'
#' @param data A data frame containing the raw tags dataset.
#' @return A cleaned data frame with properly formatted UserID, MovieID, Tag, and Timestamp.
preprocess_tags <- function(data) {
  cat("\nPreprocessing Tags Data...\n")
  
  data <- data %>%
    mutate(Timestamp = as.POSIXct(timestamp, origin = "1970-01-01")) %>%
    select(UserID = userId, MovieID = movieId, Tag = tag, Timestamp)
  
  cat("\nFinished preprocessing Tags data.\n")
  return(data)
}

#' Preprocess the Links Dataset
#'
#' This function preprocesses the links dataset by renaming columns for clarity
#' and ensuring the dataset is structured correctly for merging with other datasets.
#'
#' @param data A data frame containing the raw links dataset.
#' @return A cleaned data frame with properly formatted MovieID, IMDbID, and TMDBID.
preprocess_links <- function(data) {
  cat("\nPreprocessing Links Data...\n")
  
  data <- data %>%
    select(MovieID = movieId, IMDbID = imdbId, TMDBID = tmdbId)
  
  cat("\nFinished preprocessing Links data.\n")
  return(data)
}

#' Calculate Aggregate Ratings for Movies and Users
#'
#' This function calculates the average ratings for each movie and each user
#' from the ratings dataset. It merges these averages back into the original ratings
#' dataset for further analysis.
#'
#' @param ratings_data A data frame containing the cleaned ratings dataset.
#' @return A data frame with additional columns for MovieAvgRating and UserAvgRating.
calculate_aggregates <- function(ratings_data) {
  cat("\nCalculating MovieAvgRating and UserAvgRating...\n")
  
  # Movie Average Rating
  movie_avg_ratings <- ratings_data %>%
    group_by(MovieID) %>%
    summarise(MovieAvgRating = mean(Rating, na.rm = TRUE))
  
  # User Average Rating
  user_avg_ratings <- ratings_data %>%
    group_by(UserID) %>%
    summarise(UserAvgRating = mean(Rating, na.rm = TRUE))
  
  # Merge back to ratings dataset
  ratings_data <- ratings_data %>%
    left_join(movie_avg_ratings, by = "MovieID") %>%
    left_join(user_avg_ratings, by = "UserID")
  
  cat("\nFinished calculating aggregate ratings.\n")
  return(ratings_data)
}

# Notes:
# - Preprocess the raw movies dataset to clean and format it for analysis.
# - This includes extracting the year from the title, trimming whitespace, and splitting genres into lists.
movies_cleaned <- preprocess_movies(raw_movies_dataset)

# Check for missing values in the cleaned movies dataset.
# Notes:
# - Identify any columns with missing values and print a summary.
# - If any missing values are found, they will be handled by removing the rows with missing data.
movies_cleaned <- check_missing_values(movies_cleaned, "Movies Dataset")

# Remove duplicate rows from the cleaned movies dataset.
# Notes:
# - Ensure that there are no duplicate entries in the dataset to maintain data integrity.
movies_cleaned <- remove_duplicates(movies_cleaned, "Movies Dataset")

# Concatenate the list of genres into a single string for each movie.
# Notes:
# - This transforms the genres from a list format into a single string, separated by '|'.
movies_cleaned <- movies_cleaned %>%
  mutate(Genres = sapply(Genres, function(x) paste(x, collapse = "|")))

# Preprocess ratings dataset
# Notes:
# - Apply the preprocessing function to the raw ratings dataset to clean and format the data.
ratings_cleaned <- preprocess_ratings(raw_ratings_dataset)

# Check for missing values in the cleaned ratings dataset.
# Notes:
# - Identify any columns with missing values and handle them appropriately.
ratings_cleaned <- check_missing_values(ratings_cleaned, "Ratings Dataset")

# Remove duplicate rows from the cleaned ratings dataset.
# Notes:
# - Ensure that there are no duplicate entries to maintain the integrity of the ratings data.
ratings_cleaned <- remove_duplicates(ratings_cleaned, "Ratings Dataset")

# Calculate MovieAvgRating and UserAvgRating for the cleaned ratings dataset.
# Notes:
# - This function computes the average rating for each movie and user, enhancing the dataset for further analysis.
ratings_cleaned <- calculate_aggregates(ratings_cleaned)

# Preprocess tags dataset.
# Notes:
# - Apply the preprocessing function to the raw tags dataset to clean and format the data for analysis.
tags_cleaned <- preprocess_tags(raw_tags_dataset)

# Check for missing values in the cleaned tags dataset.
# Notes:
# - Identify any columns with missing values and handle them accordingly.
tags_cleaned <- check_missing_values(tags_cleaned, "Tags Dataset")

# Remove duplicate rows from the cleaned tags dataset.
# Notes:
# - Ensure that there are no duplicate entries to maintain the integrity of the tags data.
tags_cleaned <- remove_duplicates(tags_cleaned, "Tags Dataset")

# Preprocess links dataset.
# Notes:
# - Apply the preprocessing function to the raw links dataset to clean and format the data.
links_cleaned <- preprocess_links(raw_links_dataset)

# Check for missing values in the cleaned links dataset.
# Notes:
# - Identify any columns with missing values and handle them appropriately.
links_cleaned <- check_missing_values(links_cleaned, "Links Dataset")

# Remove duplicate rows from the cleaned links dataset.
# Notes:
# - Ensure that there are no duplicate entries to maintain the integrity of the links data.
links_cleaned <- remove_duplicates(links_cleaned, "Links Dataset")

# Save the cleaned movies dataset as a CSV file in the preprocessed folder.
# Notes:
# - This writes the cleaned movies data to a CSV file without row names.
write.csv(movies_cleaned, file = "data/preprocessed/movies_cleaned.csv", row.names = FALSE)

# Save the cleaned ratings dataset as a CSV file in the preprocessed folder.
# Notes:
# - This writes the cleaned ratings data to a CSV file without row names.
write.csv(ratings_cleaned, file = "data/preprocessed/ratings_cleaned.csv", row.names = FALSE)

# Save the cleaned tags dataset as a CSV file in the preprocessed folder.
# Notes:
# - This writes the cleaned tags data to a CSV file without row names.
write.csv(tags_cleaned, file = "data/preprocessed/tags_cleaned.csv", row.names = FALSE)

# Save the cleaned links dataset as a CSV file in the preprocessed folder.
# Notes:
# - This writes the cleaned links data to a CSV file without row names.
write.csv(links_cleaned, file = "data/preprocessed/links_cleaned.csv", row.names = FALSE)
