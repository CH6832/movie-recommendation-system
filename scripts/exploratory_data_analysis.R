# ----------------------------------------------------------------------------------------
# Title:        exploratory_data_analysis.R
# Author:       Christoph Hartleb
# Date:         2024-10-02
# Description:  The script performs exploratory data analysis (EDA) on a movie dataset,
#               focusing on tasks like data cleaning, transformation, and visualization. 
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

# Load utility scripts for additional functions.
source("scripts/utils.R")

# Check if required packages are installed.
check_pkg_status(c("dplyr","ggplot2","tidyr","stringr","summarytools","ggcorrplot","corrplot","caret","psych","FactoMineR","factoextra","lubridate","reshape2"))

library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)
library(lubridate)

# Each dataset is loaded using a custom load_dataset function, assuming
# it handles the reading of CSV files and any necessary preprocessing.
raw_movies_dataset <- load_dataset("data/raw/ml-latest-small/movies.csv")
raw_ratings_dataset <- load_dataset("data/raw/ml-latest-small/ratings.csv")
raw_tags_dataset <- load_dataset("data/raw/ml-latest-small/tags.csv")
raw_links_dataset <- load_dataset("data/raw/ml-latest-small/links.csv")

# Clean and format the movies dataset.
# Notes:
# - The following operations are performed:
#   - Extract the year from the title using a regex pattern.
#   - Remove the year from the title for cleaner representation.
#   - Split the genres into a list for further analysis.
data_movies <- raw_movies_dataset %>%
  mutate(Year = as.numeric(str_extract(title, "\\d{4}")), # Extract year from title.
         Title = str_replace(title, "\\s*\\(\\d{4}\\)", ""), # Clean title by removing year.
         Genres = str_split(genres, "\\|")) %>% # Split genres into a list format.
  unnest(Genres) %>% # Expand the list of genres into separate rows.
  select(MovieID = movieId, Title, Year, Genres) %>% # Select relevant columns and rename them.
  mutate(MovieID = as.numeric(MovieID)) # Ensure MovieID is numeric.
data_movies # Display the cleaned movies dataset.

# Clean and format the ratings dataset.
# Notes:
# - Select relevant columns and rename them for clarity.
# - Convert the timestamp to a POSIXct date-time format for easier handling of dates.
data_ratings <- raw_ratings_dataset %>%
  select(UserID = userId, MovieID = movieId, Rating = rating, Timestamp = timestamp) %>%  # Select and rename columns.
  mutate(Timestamp = as.POSIXct(Timestamp, origin = "1970-01-01"))  # Convert timestamp to date-time.
data_ratings  # Display the cleaned ratings dataset.

# Select relevant columns and rename them for clarity.
data_links <- raw_links_dataset %>%
  # Select and rename columns.
  select(MovieID = movieId, IMDbID = imdbId, TMDBID = tmdbId)
data_links

# Clean and format the tags dataset.
data_tags <- raw_tags_dataset %>%
  # Select relevant columns and rename them for clarity.
  select(UserID = userId, MovieID = movieId, Tag = tag, Timestamp = timestamp) %>%
  # Convert the timestamp to a POSIXct date-time format for easier handling of dates.
  mutate(Timestamp = as.POSIXct(Timestamp, origin = "1970-01-01"))
data_tags

#' Perform initial data exploration on cleaned datasets
#'
#' This function provides a preliminary exploration of the cleaned datasets by displaying 
#' their structures. It uses the `str()` function to show the data types and dimensions 
#' of the datasets, which is essential for understanding the data's organization 
#' before further analysis.
#'
#' @return This function does not return any value; it simply prints the structure of 
#' the cleaned datasets (`data_movies`, `data_ratings`, `data_links`, `data_tags`) 
#' to the console for review.
first_data_exploration <- function() {
  str(data_movies)
  str(data_ratings)
  str(data_links)
  str(data_tags)
  
  # Return NULL invisibly as no output is needed.
  return(invisible(NULL)) 
}
first_data_exploration()

#' Calculate summary statistics for the movies dataset
#'
#' This function computes various summary statistics for the cleaned movies dataset, 
#' including mean, median, and variance for both MovieID and Year. 
#' These statistics provide insights into the distribution and characteristics of the data.
#'
#' @param data A data frame containing the cleaned movies dataset, which should include 
#' columns for MovieID and Year.
#' @return A data frame with summary statistics, including:
#'   - mean_movieID: The average MovieID.
#'   - median_movieID: The median value of MovieID.
#'   - var_movieID: The variance of MovieID.
#'   - mean_year: The average year of movie releases.
#'   - median_year: The median year of movie releases.
#'   - var_year: The variance of movie release years.
calc_movie_stats <- function(data) {
  summary_stats <- data %>%
    summarise(
      mean_movieID = mean(MovieID, na.rm = TRUE),  # Mean of MovieID
      median_movieID = median(MovieID, na.rm = TRUE),  # Median of MovieID
      var_movieID = var(MovieID, na.rm = TRUE),  # Variance of MovieID
      mean_year = mean(Year, na.rm = TRUE),  # Mean of Year
      median_year = median(Year, na.rm = TRUE),  # Median of Year
      var_year = var(Year, na.rm = TRUE)  # Variance of Year
    )
  return(summary_stats)  # Return the summary statistics
}

# Check for missing values in the movies and ratings datasets.
# Notes:
# - sapply(): Used to apply a function to each column of the dataset, counting the number of
#             missing values (NAs).
missing_values_movies <- sapply(data_movies, function(x) sum(is.na(x)))  # Count missing values in movies dataset
missing_values_ratings <- sapply(data_ratings, function(x) sum(is.na(x)))  # Count missing values in ratings dataset

#' Plot the distribution of movies by year
#'
#' This function creates a histogram that visualizes the distribution of 
#' movies released each year, helping to identify trends and patterns over time.
#'
#' @param data_movies A data frame containing the cleaned movies dataset, 
#' which should include a column for the year of release.
#' @return A ggplot object representing the histogram of movie counts by year, 
#' which can be printed or further customized.
plot_movies_year_distribution <- function(data_movies) {
  plot <- ggplot(data_movies, aes(x = Year)) +  # Define the aesthetic mapping for the plot
    geom_histogram(bins = 20, fill = "lightblue", color = "black") +  # Create histogram bars
    theme_minimal() +  # Apply a minimal theme to the plot
    labs(title = "Distribution of Movies by Year", x = "Year", y = "Count")  # Add titles and labels
  
  return(plot) # Return the plot object
}

plot_movies_year_distribution(data_movies)  # Call the function to generate the plot

#' Explore the structure of the datasets
#'
#' This function performs an initial exploration of the cleaned datasets, 
#' providing information about the structure and types of the variables 
#' within the movies, ratings, links, and tags datasets.
#'
#' @return NULL This function does not return a value. It prints the 
#' structure of the datasets to the console for inspection.
first_data_exploration <- function() {
  str(data_movies)
  str(data_ratings)
  str(data_links)
  str(data_tags)
  
  return(invisible(NULL))
}

#' Calculate summary statistics for the movies dataset
#'
#' This function computes summary statistics, including mean, median, 
#' and variance for the MovieID and Year columns of the movies dataset.
#'
#' @param data A data frame containing the cleaned movies dataset.
#' @return A data frame with summary statistics including mean, median, 
#' and variance for MovieID and Year.
calc_movie_stats <- function(data) {
  summary_stats <- data %>%
    summarise(
      mean_movieID = mean(MovieID, na.rm = TRUE),
      median_movieID = median(MovieID, na.rm = TRUE),
      var_movieID = var(MovieID, na.rm = TRUE),
      mean_year = mean(Year, na.rm = TRUE),
      median_year = median(Year, na.rm = TRUE),
      var_year = var(Year, na.rm = TRUE)
    )
  return(summary_stats)
}

#' Plot the distribution of movies by year
#'
#' This function generates a histogram that visualizes the distribution 
#' of movies released each year, helping to understand trends over time.
#'
#' @param data_movies A data frame containing the cleaned movies dataset.
#' @return A ggplot object representing the histogram of movie counts by year, 
#' which can be printed or further customized.
plot_movies_year_distribution <- function(data_movies) {
  plot <- ggplot(data_movies, aes(x = Year)) +
    geom_histogram(bins = 20, fill = "lightblue", color = "black") +
    theme_minimal() +
    labs(title = "Distribution of Movies by Year", x = "Year", y = "Count")
  
  return(plot)
}

#' Plot the distribution of ratings
#'
#' This function creates a histogram visualizing the distribution of user ratings,
#' which helps identify user preferences and rating tendencies.
#'
#' @param data_ratings A data frame containing the cleaned ratings dataset.
#' @return A ggplot object representing the histogram of ratings distribution, 
#' which can be printed or further customized.
plot_ratings_distribution <- function(data_ratings) {
  plot <- ggplot(data_ratings, aes(x = Rating)) +
    geom_histogram(bins = 10, fill = "orange", color = "black") +
    theme_minimal() +
    labs(title = "Distribution of Ratings", x = "Rating", y = "Count")
  
  return(plot)
}

# Select numerical columns for correlation.
numeric_cols <- select(data_movies, MovieID, Year)

# Calculate the correlation matrix.
corr_matrix <- cor(numeric_cols, use = "complete.obs")

# Visualize the correlation matrix with labels.
ggcorrplot(corr_matrix, lab = TRUE)
