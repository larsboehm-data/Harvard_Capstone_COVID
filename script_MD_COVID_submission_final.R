###############################################################################
# HarvardX PH125.9x - Data Science Capstone Project
# Choose-Your-Own Project: Predicting cumulative COVID-19 incidence in Germany
# Author: Lars Böhm, MD
# Date:   May 8, 2026
#
# This script performs the machine-learning task used in the accompanying Rmd
# report. It automatically downloads the two required data files from the public
# project repository, cleans and joins the data, builds baseline, linear, and
# random forest regression models, evaluates RMSE on a holdout test set, and
# writes the main model outputs to disk.
#
# Clinical/educational motivation: the project was designed by a physician in
# internal medicine training to retrospectively explore German COVID-19 data with
# data-science methods learned during HarvardX PH125.9x. The analysis is an
# educational epidemiological modelling exercise and not a clinical prediction
# tool for individual patient care.
#
# Generative AI disclosure: OpenAI ChatGPT was used as a limited support tool for
# RMarkdown/R formatting, language refinement, code review, and debugging
# suggestions. The research question, medical interpretation, final code review,
# and submission responsibility remain with the author.
###############################################################################

# ---- 1. Load required packages ----
required_pkgs <- c("tidyverse", "data.table", "caret", "randomForest")

# Automatically install missing packages as requested in the project rubric.
for (pkg in required_pkgs) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(caret)
  library(randomForest)
})

set.seed(2026)

# ---- 2. Data acquisition ----
url_repo <- "https://github.com/larsboehm-data/Harvard_Capstone_COVID"
url_inf  <- "https://raw.githubusercontent.com/larsboehm-data/Harvard_Capstone_COVID/main/covid_de.csv.zip"
url_demo <- "https://raw.githubusercontent.com/larsboehm-data/Harvard_Capstone_COVID/main/demographics_de.csv"

load_zipped_github_csv <- function(url) {
  zip_file <- tempfile(fileext = ".zip")
  extract_dir <- tempfile(pattern = "covid_zip_")
  dir.create(extract_dir, recursive = TRUE, showWarnings = FALSE)

  on.exit(unlink(c(zip_file, extract_dir), recursive = TRUE, force = TRUE), add = TRUE)

  download_ok <- tryCatch({
    utils::download.file(url, zip_file, mode = "wb", quiet = TRUE)
    TRUE
  }, error = function(e) e)

  if (inherits(download_ok, "error")) {
    stop("Could not download ", url, ": ", conditionMessage(download_ok))
  }

  zip_contents <- unzip(zip_file, list = TRUE)
  csv_files <- zip_contents$Name[grepl("\\.csv$", zip_contents$Name, ignore.case = TRUE)]

  if (length(csv_files) == 0) {
    stop("No CSV file found inside the downloaded ZIP archive.")
  }

  csv_path <- unzip(zip_file, files = csv_files[1], exdir = extract_dir)
  data.table::fread(csv_path)
}

read_url_text <- function(url) {
  tmp_file <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_file, force = TRUE), add = TRUE)

  download_ok <- tryCatch({
    utils::download.file(url, tmp_file, mode = "wb", quiet = TRUE)
    TRUE
  }, error = function(e) e)

  if (inherits(download_ok, "error")) {
    stop("Could not download ", url, ": ", conditionMessage(download_ok))
  }

  paste(readLines(tmp_file, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
}

load_demographics_csv <- function(url) {
  txt <- read_url_text(url)
  txt <- gsub("\\r\\n|\\r", "\n", txt)

  n_lines <- length(strsplit(txt, "\n", fixed = TRUE)[[1]])

  # Repair fallback: if the hosted file is stored as one long line, insert row
  # breaks before each federal-state / gender combination.
  if (n_lines <= 2) {
    federal_states <- c(
      "Baden-Wuerttemberg", "Bayern", "Berlin", "Brandenburg", "Bremen",
      "Hamburg", "Hessen", "Mecklenburg-Vorpommern", "Niedersachsen",
      "Nordrhein-Westfalen", "Rheinland-Pfalz", "Saarland", "Sachsen",
      "Sachsen-Anhalt", "Schleswig-Holstein", "Thueringen"
    )

    row_boundary <- paste0(" (?=(", paste(federal_states, collapse = "|"), "),(female|male),)")
    txt <- gsub(row_boundary, "\n", txt, perl = TRUE)
  }

  data.table::fread(text = txt)
}

cat("Downloading project data from:\n", url_repo, "\n\n")
covid_data <- load_zipped_github_csv(url_inf)
demo_data  <- load_demographics_csv(url_demo)

cat("COVID data dimensions:      ", nrow(covid_data), "rows x", ncol(covid_data), "columns\n")
cat("Demographic data dimensions:", nrow(demo_data), "rows x", ncol(demo_data), "columns\n")

# ---- 3. Data cleaning and feature engineering ----
required_covid_cols <- c("state", "age_group", "gender", "cases")
required_demo_cols  <- c("state", "age_group", "gender", "population")

missing_covid_cols <- setdiff(required_covid_cols, names(covid_data))
missing_demo_cols  <- setdiff(required_demo_cols, names(demo_data))

if (length(missing_covid_cols) > 0) {
  stop("Missing columns in covid_data: ", paste(missing_covid_cols, collapse = ", "))
}

if (length(missing_demo_cols) > 0) {
  stop("Missing columns in demo_data: ", paste(missing_demo_cols, collapse = ", "))
}

clean_state <- function(x) {
  x <- stringr::str_squish(as.character(x))
  x <- stringr::str_replace_all(
    x,
    c(
      "Ä" = "Ae", "Ö" = "Oe", "Ü" = "Ue",
      "ä" = "ae", "ö" = "oe", "ü" = "ue", "ß" = "ss"
    )
  )
  stringr::str_to_lower(x)
}

clean_key <- function(x) {
  stringr::str_to_lower(stringr::str_squish(as.character(x)))
}

clean_gender <- function(x) {
  x <- clean_key(x)
  dplyr::case_when(
    x %in% c("f", "female", "weiblich", "w") ~ "female",
    x %in% c("m", "male", "maennlich", "männlich") ~ "male",
    TRUE ~ x
  )
}

cases_prep <- covid_data %>%
  mutate(
    state = clean_state(state),
    age_group = clean_key(age_group),
    gender = clean_gender(gender),
    cases = as.numeric(cases)
  ) %>%
  filter(gender %in% c("female", "male"), !is.na(age_group)) %>%
  group_by(state, gender, age_group) %>%
  summarise(total_cases = sum(cases, na.rm = TRUE), .groups = "drop")

demo_prep <- demo_data %>%
  mutate(
    state = clean_state(state),
    age_group = clean_key(age_group),
    gender = clean_gender(gender),
    population = as.numeric(population)
  ) %>%
  filter(gender %in% c("female", "male"), !is.na(population), population > 0)

unmatched_cases <- anti_join(cases_prep, demo_prep, by = c("state", "gender", "age_group"))

if (nrow(unmatched_cases) > 0) {
  message("Warning: ", nrow(unmatched_cases), " aggregated case strata have no matching population data.")
  print(head(unmatched_cases, 10))
}

final_df <- cases_prep %>%
  inner_join(demo_prep, by = c("state", "gender", "age_group")) %>%
  mutate(incidence = (total_cases / population) * 100000) %>%
  mutate(across(c(state, gender, age_group), as.factor))

if (nrow(final_df) == 0) {
  stop("The joined data set is empty. Check state, gender, and age-group coding.")
}

if (any(is.na(final_df$incidence))) {
  stop("Incidence contains missing values after joining case and population data.")
}

cat("\nRows used for modelling:", nrow(final_df), "\n")

# ---- 4. Train/test split ----
set.seed(2026)
test_index <- caret::createDataPartition(
  y = final_df$incidence,
  times = 1,
  p = 0.20,
  list = FALSE
)

train_set <- final_df[-test_index, , drop = FALSE]
test_set  <- final_df[ test_index, , drop = FALSE]

cat("Training rows:", nrow(train_set), "\n")
cat("Test rows:    ", nrow(test_set), "\n")

# ---- 5. Model training and evaluation ----
rmse <- function(actual, predicted) {
  sqrt(mean((actual - predicted)^2))
}

baseline_prediction <- mean(train_set$incidence)
baseline_predictions <- rep(baseline_prediction, nrow(test_set))
baseline_rmse <- rmse(test_set$incidence, baseline_predictions)

fit_lm <- stats::lm(incidence ~ state + gender + age_group, data = train_set)
lm_predictions <- as.numeric(predict(fit_lm, newdata = test_set))
lm_rmse <- rmse(test_set$incidence, lm_predictions)

fit_rf <- randomForest::randomForest(
  incidence ~ state + gender + age_group,
  data = train_set,
  ntree = 500,
  importance = TRUE
)

rf_predictions <- as.numeric(predict(fit_rf, newdata = test_set))
rf_rmse <- rmse(test_set$incidence, rf_predictions)

mean_test_incidence <- mean(test_set$incidence)
relative_error <- function(model_rmse) {
  if (mean_test_incidence == 0) {
    return(NA_real_)
  }
  100 * model_rmse / mean_test_incidence
}

results <- tibble::tibble(
  model = c("Mean baseline", "Linear regression", "Random forest"),
  rmse = c(baseline_rmse, lm_rmse, rf_rmse),
  relative_error_percent = c(
    relative_error(baseline_rmse),
    relative_error(lm_rmse),
    relative_error(rf_rmse)
  )
) %>%
  arrange(rmse)

cat("\n===== Final Results =====\n")
print(results)

# ---- 6. Write reproducibility outputs ----
readr::write_csv(results, "model_results.csv")
readr::write_csv(
  tibble::tibble(
    observed = test_set$incidence,
    mean_baseline = baseline_predictions,
    linear_regression = lm_predictions,
    random_forest = rf_predictions
  ),
  "model_predictions.csv"
)

importance_df <- as.data.frame(randomForest::importance(fit_rf))
importance_df$feature <- rownames(importance_df)
importance_df <- importance_df %>% relocate(feature)
if ("IncNodePurity" %in% names(importance_df)) {
  importance_df <- importance_df %>% arrange(desc(IncNodePurity))
}
readr::write_csv(importance_df, "feature_importance_table.csv")

pdf("feature_importance_random_forest.pdf", width = 7, height = 5)
randomForest::varImpPlot(fit_rf, main = "Predictive Power of Demographic Variables")
dev.off()

cat("\nOutput files written:\n")
cat("- model_results.csv\n")
cat("- model_predictions.csv\n")
cat("- feature_importance_table.csv\n")
cat("- feature_importance_random_forest.pdf\n")

# ---- 7. Reproducibility information ----
cat("\n===== Session Info =====\n")
print(sessionInfo())
