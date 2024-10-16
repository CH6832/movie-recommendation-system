# ----------------------------------------------------------------------------------------
# Title:        utils.R
# Author:       Christoph Hartleb
# Date:         2024-10-02
# Description:  This script provides utility functions to support data processing tasks.
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

# Load needed libraries
library(parallel) # For parallel processing if required
library(dplyr) # Data manipulation
library(stringr) # String manipulation

#' Checks if the specified R packages are installed. If a package is not 
#' found, it attempts to install it from CRAN. Informational messages are printed 
#' to indicate whether each package is already installed or has just been installed.
#'
#' @param pkgs A character vector containing the names of the packages to check.
#' @return This function does not return any value; it performs checks and installs 
#' packages as necessary.
check_pkg_status <- function(pkgs) {
  for (pkg in pkgs) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
      message(paste("INFO: '", pkg, "' has been installed."))
    } else {
      message(paste("INFO: '", pkg, "' is already installed."))
    }
  }

  return(invisible(NULL))
}

#' This function loads a CSV file into R as a data frame. It first checks if the 
#' specified file exists and stops execution if it does not. The CSV is read with 
#' headers and specified missing value strings.
#'
#' @param data_filepath A character string representing the file path to the CSV file 
#' to be loaded.
#' @return A data frame containing the contents of the CSV file.
load_dataset <- function(data_filepath) {
  # Check if file exists
  if (!file.exists(data_filepath)) {
    stop(paste("ERROR: '", data_filepath, "' does not exist."))
  }
  
  # Load the CSV dataset
  data <- read.csv(data_filepath, header = TRUE, na.strings = c("", "NA"))
  
  return(data)
}
