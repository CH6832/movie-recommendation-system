# Movie Recommendation System

## Table of Contents

- [Why Such a Project](#why-such-a-project)
- [How It Works](#how-it-works)
  - [Understanding the Business Problem](#understanding-the-business-problem)
  - [Collecting Data](#collecting-data)
  - [Exploring the Dataset (EDA)](#exploring-the-dataset-eda)
  - [Preprocessing and Cleaning](#preprocessing-and-cleaning)
  - [Feature Selection and Engineering](#feature-selection-and-engineering)
  - [Model Training, Evaluation, and Interpretation](#model-training-evaluation-and-interpretation)
  - [Predicting](#predicting)
  - [Reporting](#reporting)
- [Content Overview](#content-overview)
- [Open the Project](#open-the-project)
- [Run the Project](#run-the-project)
- [Debug the Project](#debug-the-project)
- [Resources](#resources)
- [Bug Fixes and Assistance](#bug-fixes-and-assistance)
- [License](#license)
- [Appendices](#appendices)
  - [Data Sources](#data-sources)
  - [Code Documentation](#code-documentation)
  - [References](#references)

## Why Such a Project

This project holds significant real-world value, particularly in industries where personalization is crucial for user engagement and satisfaction. By leveraging data to generate tailored movie recommendations, the system enhances the user experience and increases both user retention and customer loyalty. Personalized content suggestions can encourage users to spend more time on the platform, explore additional offerings, and remain engaged over time. This project could be especially beneficial to streaming platforms, e-commerce companies, and marketing firms.

## How It Works

### Understanding the Business Problem

The primary objective of this project is to develop a system that recommends movies to a target audience. By providing personalized movie recommendations, the project aims to enhance customer engagement with the platform, attract new users, and drive growth and retention.

### Collecting Data

The dataset utilized for this project is available at the [MovieLens 10M Dataset](http://grouplens.org/datasets/movielens/10m/), which is well-suited for efficient computation and rapid prototyping. For a more comprehensive analysis, the full dataset can be accessed here: [MovieLens Latest Datasets](https://grouplens.org/datasets/movielens/latest/).

### Exploring the Dataset (EDA)

Upon inspecting the dataset, it consists of 10 million ratings from 72,000 users on 10,000 movies. The dataset includes files such as `ratings.dat`, `movies.dat`, and `tags.dat`, which provide valuable information about the movies, users, and their interactions. Exploratory data analysis (EDA) will identify patterns and insights by analyzing key metrics like the distribution of ratings, the number of ratings per movie, and the most popular genres.

### Preprocessing and Cleaning

The preprocessing phase involves cleaning the dataset by addressing missing values, converting categorical variables to numeric formats, and removing duplicates. The ratings will be normalized, and any unnecessary columns will be discarded to ensure the data is in a suitable format for model training.

### Feature Selection and Engineering

Feature selection and engineering are critical for enhancing model performance. Key features, such as user and movie IDs, genres, and average ratings, will be extracted and transformed. New features, such as the number of ratings per user or average ratings per movie, may also be created to improve the recommendation system's accuracy.

### Model Training, Evaluation, and Interpretation

Initially, various recommendation algorithms were considered, including collaborative filtering, content-based filtering, and hybrid approaches. After evaluating these models using metrics such as Root Mean Square Error (RMSE) and Mean Absolute Error (MAE), the Random Forest model demonstrated superior performance. Therefore, it was selected as the final model for further use, as it provided the most accurate predictions.

### Predicting

Once the model is trained, it can generate predictions for users. By inputting a user's past ratings and preferences, the model will produce a list of recommended movies tailored specifically to that user. These recommendations will be ranked based on predicted ratings, enabling users to discover new content that aligns with their interests.

### Reporting

The final phase involves reporting the findings and performance of the recommendation system. Visualizations and summary statistics will illustrate the model's effectiveness. This report will also discuss potential improvements and future work that could enhance the recommendation system further.

## Content Overview

    .
    ├── data/ - Directory for storing all datasets.
    │   ├── processed/ - Contains preprocessed data used for modeling.
    │   └── raw/ - Contains raw, unprocessed datasets.
    ├── model/ - Directory for storing the trained machine learning models and related outputs.
    ├── reports/ - Contains generated reports, including the final report.
    ├── scripts/ - Directory for storing all R scripts for the project.
    │   ├── data_preprocessing.R - Script for cleaning and preprocessing the dataset.
    │   ├── exploratory_data_analysis.R - Script for performing exploratory data analysis.
    │   ├── feature_engineering.R - Script for creating new features for the model.
    │   ├── generate_test_data.R - Script for generating test datasets.
    │   ├── ml_model_training.R - Script for training the machine learning model.
    │   ├── ml_model_validation.R - Script for evaluating the model and generating performance metrics.
    │   └── utils.R - Utility functions used across scripts.
    ├── LICENSE - Project license file.
    ├── movie-recommendation-system.Rproj - R project file.
    ├── README.md - Project documentation in Markdown format.
    └── renv.lock - Lockfile for the R environment.

## Open the Project

0. **Download the repository:**  
   To open the project, you first need to download the repository:
   
   ```bash
   git clone https://github.com/CH6832/movie-recommendation-system.git
   cd movie-recommendation-system
   ```

1. **Open with RStudio:**  
   - Download and install RStudio from [Posit](https://posit.co/download/rstudio-desktop/).
   - Open [**RStudio**](https://rstudio-education.github.io/hopr/starting.html) on your device.
   - Click on `File` -> `Open Project ...` and select the folder containing the project.

---

## Run the Project

To execute the project, several scripts need to be run in a specific order to ensure the correct flow from data loading to model validation. Each script is responsible for a key part of the analysis, including data preprocessing, feature engineering, model training, and evaluation.

1. **Install Required Libraries**: Before running the scripts, make sure that all required libraries are installed by executing the following command in the R console:

```R
install.packages(c("dplyr", "ggplot2", "caret", "recommenderlab", "tidyr", "caret", "readr", "stringr", "lubridate", "tidyverse", "randomForest"))
```

2. **Run the Scripts in Order**: The scripts must be executed in the following order to properly process the data and train the model:

**Exploratory Data Analysis**:
- This script provides an initial overview and analysis of the dataset:
```R
scripts/exploratory_data_analysis.R
```

**Data Preprocessing**:
- This script cleans the data and prepares it for modeling by handling missing values and applying necessary transformations:
```R
scripts/data_preprocessing.R
```

**Feature Engineering**:
- This script generates additional features that will enhance model performance:
```R
scripts/feature_engineering.R
```

**Model Training**:
- This script trains the Random Forest model on the processed dataset:
```R
scripts/ml_model_training.R
```

**Model Validation**:
- This script evaluates the model on test data and produces performance metrics such as RMSE and visualizations:
```R
scripts/ml_model_validation.R
```

By following this order, you ensure that the data is properly prepared and the machine learning model is trained and validated effectively. Each script plays a vital role in the overall workflow, and running them sequentially guarantees the correct execution of the entire project.

## Debug the Project

If you encounter any issues while running the project, ensure that all dependencies are properly installed by checking the **`renv.lock`** file for package versions and running `renv::restore()` to install any missing packages. If problems persist, consider the following debugging steps:

1. **Console Output**: Check the R console for error messages or warnings that may indicate missing files, incorrect paths, or unsupported function calls.
   
2. **Scripts Directory**: Review the code in the `scripts/` directory, where all data preprocessing, model training, and evaluation functions are stored. Docstrings and comments are provided throughout the code to make troubleshooting easier.

3. **Working Directory**: Ensure that your working directory is set correctly in RStudio, as incorrect paths to the data or scripts can cause errors. You can use the `setwd()` function to manually specify the correct directory.

4. **Dependency Conflicts**: If you're using multiple R environments or projects, consider using `renv` to isolate package dependencies. If you are not using `renv`, verify that the correct versions of required packages are installed by checking the `DESCRIPTION` file.

5. **Reproducibility**: To ensure reproducibility and a clean environment, restarting R (`Ctrl + Shift + F10` in RStudio) and rerunning the scripts can resolve some unexpected behaviors.

6. **Alternative IDEs**: While the project is designed for RStudio, it can also be run in other IDEs or editors that support R, such as:
   - [**Visual Studio Code** (with the **R** extension installed)](https://code.visualstudio.com/docs/languages/r)
   - [**Jupyter Notebook** (using **IRkernel** for R support)](https://developers.lseg.com/en/article-catalog/article/setup-jupyter-notebook-r)
   - [**Emacs** (with the **ESS** package for R)](https://ess.r-project.org/)
   - [**R.app** on macOS or **R GUI** on Windows/Linux](https://www.r-project.org/)
   - [**Sublime Text** (with R plugins like **R-Box**)](https://rpubs.com/shreyasl/sublimeR)

   In each case, ensure that paths and dependencies are correctly configured for your chosen environment.

7. **Debugging Functions**: You can use R's built-in debugging tools such as `debug()`, `browser()`, or `traceback()` to step through code and inspect variables at different stages.

### Bug Fixes and Assistance

The source code, project structure, text, and core ideas throughout the analysis were originally conceived and developed by me.

Bug fixes, typo corrections, and improvements to spelling were completed with the assistance of [**ChatGPT (GPT-4)**](https://openai.com/index/gpt-4/), an AI language model developed by OpenAI. This tool was used to enhance code quality and ensure clarity in the documentation, without altering the underlying concepts or direction of the project.

## License

This project is licensed under the [Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)](https://creativecommons.org/licenses/by-nc-nd/4.0/deed.en) License. Please see the [LICENSE](LICENSE) file for detailed information.

---

## Appendices

### Data Sources

- **MovieLens 10M Dataset:** Available at [MovieLens Datasets](https://grouplens.org/datasets/movielens/).

### Code Documentation

All code used for data preprocessing, model training, and evaluation can be found in the `scripts/` directory. Each script is well-documented with docstrings and in-line comments, making it easy and convenient to understand and navigate the code.

### General Documentations

- [**Intro to R**](https://cran.r-project.org/doc/manuals/r-release/R-intro.pdf)

- [**RStudio IDE User Guide**](https://docs.posit.co/ide/user/)

### Package Documentations

- **caret**: [https://cran.r-project.org/web/packages/caret/caret.pdf](https://cran.r-project.org/web/packages/caret/caret.pdf)

- **dplyr**: [https://cran.r-project.org/web/packages/dplyr/dplyr.pdf](https://cran.r-project.org/web/packages/dplyr/dplyr.pdf)

- **ggplot2**: [https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf](https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf)

- **lubridate**: [https://cran.r-project.org/web/packages/lubridate/lubridate.pdf](https://cran.r-project.org/web/packages/lubridate/lubridate.pdf)

- **randomForest**: [https://cran.r-project.org/web/packages/randomForest/randomForest.pdf](https://cran.r-project.org/web/packages/randomForest/randomForest.pdf)

- **recommenderlab**: [https://cran.r-project.org/web/packages/recommenderlab/recommenderlab.pdf](https://cran.r-project.org/web/packages/recommenderlab/recommenderlab.pdf)

- **stringr**: [https://cran.r-project.org/web/packages/stringr/stringr.pdf](https://cran.r-project.org/web/packages/stringr/stringr.pdf)

- **tidyverse**: [https://cran.r-project.org/web/packages/tidyverse/tidyverse.pdf](https://cran.r-project.org/web/packages/tidyverse/tidyverse.pdf)

### References

- Leisch, Friedrich et al. (2002): *Classification and Regression by randomForest*, in: R News - The Newsletter of the R Project, available at: [https://cran.r-project.org/doc/Rnews/Rnews_2002-3.pdf](https://cran.r-project.org/doc/Rnews/Rnews_2002-3.pdf), last visited: 2024-10-01
- MIT OpenCourseware (2017), 15.071 | Spring 2017 | Graduate The Analytics Edge, *4.2 Judge, Jury, and Classifier: An Introduction to Trees*, available at: [https://ocw.mit.edu/courses/15-071-the-analytics-edge-spring-2017/pages/trees/judge-jury-and-classifier-an-introduction-to-trees/video-5-random-forests/](https://ocw.mit.edu/courses/15-071-the-analytics-edge-spring-2017/pages/trees/judge-jury-and-classifier-an-introduction-to-trees/video-5-random-forests/), last visited: 2024-10-13
- Breiman, L. (2001), Random Forests, *Machine Learning*, 45(1), 5-32, available at: [https://www.stat.berkeley.edu/~breiman/randomforest2001.pdf](https://www.stat.berkeley.edu/~breiman/randomforest2001.pdf), last visited: 2024-10-13
- GroupLens Research (2024), *MovieLens 10M Dataset*, available at: [https://grouplens.org/datasets/movielens/](https://grouplens.org/datasets/movielens/), last visited: 2024-10-13
