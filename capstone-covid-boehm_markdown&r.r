{
 "cells": [
  {
   "cell_type": "markdown",
   "id": "84034b40",
   "metadata": {
    "papermill": {
     "duration": 0.002084,
     "end_time": "2026-05-08T04:06:13.172205",
     "exception": false,
     "start_time": "2026-05-08T04:06:13.170121",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "# HarvardX: PH125.9x Data Science - Capstone Project\n",
    "## Epidemiological Prediction of COVID-19 Incidence in Germany: A Retrospective Machine Learning Study\n",
    "**Author:** Lars Böhm, MD  \n",
    "**Date:** May 8, 2026\n",
    "\n",
    "## 1. Introduction\n",
    "The COVID-19 pandemic (2020–2022) served as a global stress test for healthcare systems worldwide. Looking back from 2026, we now have access to finalized, high-resolution datasets provided by the Robert Koch Institute (RKI). As a medical professional with experience in emergency medicine, I witnessed firsthand how critical regional data accuracy is for hospital resource management, ICU capacity planning, and staffing.\n",
    "\n",
    "The motivation for this project is to utilize this historical \"big data\" to validate whether machine learning can accurately predict infection clusters based on core demographic variables. While the acute phase of the pandemic has passed, the methodology developed here serves as a **clinical blueprint for future pandemic preparedness**. By identifying how age, gender, and regionality drove the 7-day incidence in the past, we can build more resilient, data-driven early warning systems for future emerging infectious diseases.\n",
    "\n",
    "## 2. Methodology\n",
    "This project employs a **retrospective cohort analysis** using the official German COVID-19 dataset. To ensure scientific transparency and full reproducibility—core requirements for the HarvardX Capstone—the data was integrated from multiple sources and is hosted in a public GitHub repository (`larsboehm-data/Harvard_Capstone_COVID`).\n",
    "\n",
    "**Key components of the methodology include:**\n",
    "* **Target Variable:** The 7-day incidence rate, normalized per 100,000 inhabitants. This standardization is essential in epidemiology to compare regions of varying population densities (e.g., urban centers vs. rural districts).\n",
    "$$\\text{Incidence} = \\frac{\\text{Total Cases}}{\\text{Population}} \\times 100,000$$\n",
    "* **Feature Selection:** The model focuses on three core predictors: **Age Group, Gender, and Federal State (Bundesland)**. These represent the primary axes of social exposure and biological vulnerability.\n",
    "* **Data Engineering:** A significant technical challenge was the \"Data Join\" between infection records and demographic census data. This required precise string standardization and mapping of categorical labels (e.g., gender codes) to ensure the integrity of the incidence calculation.\n",
    "* **Model Selection:** A **Random Forest** algorithm was chosen. This ensemble method is superior for capturing non-linear interactions between geography and demographics, which traditional linear models often fail to represent in complex epidemiological settings.\n",
    "\n",
    "## 3. Results & Model Performance\n",
    "The Random Forest model was evaluated using a 20% holdout test set. The results demonstrate a high level of predictive stability despite the inherent variance of infectious disease data.\n",
    "\n",
    "* **Final RMSE:** 7,703.35\n",
    "* **Mean Dataset Incidence:** 41,199.73\n",
    "* **Relative Prediction Error:** ~18.7%\n",
    "\n",
    "This level of accuracy indicates that the chosen demographic features are sufficient to explain a significant portion of the regional infection dynamics.\n",
    "\n",
    "## 4. Feature Importance Analysis\n",
    "The \"Variable Importance Plot\" (IncNodePurity) provides the most critical clinical insight of this study. It ranks the predictors based on their contribution to the model's accuracy.\n",
    "\n",
    "**Key Findings:**\n",
    "1. **Age Group:** Identified as the dominant predictor. This validates the biological reality that age-stratified social mobility and immune vulnerability were the primary engines of the pandemic.\n",
    "2. **Federal State:** Ranked second, reflecting the impact of localized public health policies and regional infrastructure.\n",
    "3. **Gender:** Shown to have a negligible impact on the incidence rate, suggesting the virus spread was largely gender-neutral at the population level.\n",
    "\n",
    "## 5. Retrospective Discussion & Conclusion\n",
    "The results of this study have significant implications for future clinical and public health strategies.\n",
    "\n",
    "### 5.1 Clinical Implications\n",
    "The overwhelming importance of the 'Age Group' predictor confirms that targeted, age-stratified protection measures are statistically more effective than broad, undifferentiated population restrictions. For hospital management, these demographic markers can serve as \"leading indicators\" to forecast incoming patient loads during an outbreak.\n",
    "\n",
    "### 5.2 Final Summary\n",
    "This project successfully demonstrates that machine learning can transform raw public health data into actionable clinical insights. By integrating these techniques into modern surveillance, healthcare systems can move from reactive \"emergency modes\" to a proactive, predictive stance. As physicians, our ultimate goal is to remain one step ahead of the disease; data science is the tool that makes this possible."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "e7883c0b",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2026-05-08T04:06:13.180733Z",
     "iopub.status.busy": "2026-05-08T04:06:13.177995Z",
     "iopub.status.idle": "2026-05-08T04:06:24.676323Z",
     "shell.execute_reply": "2026-05-08T04:06:24.674330Z"
    },
    "papermill": {
     "duration": 11.504865,
     "end_time": "2026-05-08T04:06:24.678580",
     "exception": false,
     "start_time": "2026-05-08T04:06:13.173715",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Loading required package: tidyverse\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "── \u001b[1mAttaching core tidyverse packages\u001b[22m ──────────────────────── tidyverse 2.0.0 ──\n",
      "\u001b[32m✔\u001b[39m \u001b[34mdplyr    \u001b[39m 1.1.4     \u001b[32m✔\u001b[39m \u001b[34mreadr    \u001b[39m 2.1.5\n",
      "\u001b[32m✔\u001b[39m \u001b[34mforcats  \u001b[39m 1.0.0     \u001b[32m✔\u001b[39m \u001b[34mstringr  \u001b[39m 1.5.1\n",
      "\u001b[32m✔\u001b[39m \u001b[34mggplot2  \u001b[39m 3.5.1     \u001b[32m✔\u001b[39m \u001b[34mtibble   \u001b[39m 3.2.1\n",
      "\u001b[32m✔\u001b[39m \u001b[34mlubridate\u001b[39m 1.9.4     \u001b[32m✔\u001b[39m \u001b[34mtidyr    \u001b[39m 1.3.1\n",
      "\u001b[32m✔\u001b[39m \u001b[34mpurrr    \u001b[39m 1.0.2     \n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "── \u001b[1mConflicts\u001b[22m ────────────────────────────────────────── tidyverse_conflicts() ──\n",
      "\u001b[31m✖\u001b[39m \u001b[34mdplyr\u001b[39m::\u001b[32mfilter()\u001b[39m masks \u001b[34mstats\u001b[39m::filter()\n",
      "\u001b[31m✖\u001b[39m \u001b[34mdplyr\u001b[39m::\u001b[32mlag()\u001b[39m    masks \u001b[34mstats\u001b[39m::lag()\n",
      "\u001b[36mℹ\u001b[39m Use the conflicted package (\u001b[3m\u001b[34m<http://conflicted.r-lib.org/>\u001b[39m\u001b[23m) to force all conflicts to become errors\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Loading required package: data.table\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "\n",
      "Attaching package: ‘data.table’\n",
      "\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "The following objects are masked from ‘package:lubridate’:\n",
      "\n",
      "    hour, isoweek, mday, minute, month, quarter, second, wday, week,\n",
      "    yday, year\n",
      "\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "The following objects are masked from ‘package:dplyr’:\n",
      "\n",
      "    between, first, last\n",
      "\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "The following object is masked from ‘package:purrr’:\n",
      "\n",
      "    transpose\n",
      "\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Loading required package: caret\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Loading required package: lattice\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "\n",
      "Attaching package: ‘caret’\n",
      "\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "The following object is masked from ‘package:purrr’:\n",
      "\n",
      "    lift\n",
      "\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "The following object is masked from ‘package:httr’:\n",
      "\n",
      "    progress\n",
      "\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Loading required package: randomForest\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "randomForest 4.7-1.2\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Type rfNews() to see new features/changes/bug fixes.\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "\n",
      "Attaching package: ‘randomForest’\n",
      "\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "The following object is masked from ‘package:dplyr’:\n",
      "\n",
      "    combine\n",
      "\n",
      "\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "The following object is masked from ‘package:ggplot2’:\n",
      "\n",
      "    margin\n",
      "\n",
      "\n"
     ]
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Downloading data from GitHub...\n"
     ]
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Harmonizing datasets...\n"
     ]
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Final dataset rows: 192 \n"
     ]
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Training Random Forest model...\n"
     ]
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "\n",
      "--------------------------------------------\n"
     ]
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Final Results Summary\n"
     ]
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "RMSE: 7703.348 \n"
     ]
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Mean Incidence: 41199.73 \n"
     ]
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "--------------------------------------------\n"
     ]
    },
    {
     "data": {
      "image/png": "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\nf/65aJ/Vq1cPHz787bff7t69e6XvF0yrN12eY125HPcr1cXDj4tIk8nbC7U3t7jkfxWbfv4/\nDups+UqsfvmrWPs3qvleCfU1mPzs0/vejBaR+/dcKLSijQ/Wt8/ozFo29KgnIusv/oPOP7uK\n807S09MDAgLq1KmTkJBQ6Knvv/9e07S+ffuWX4HAdVEVz7Gz5SS8M3N0y4Yh9lFFM7jcenef\nj7afz+9Q6KvVnLR9Ux7p5OdiFBHNYK5e7+YuDw4RkcDwVcX2d2YQq7oq8Rw7XdeHDRsmImvX\nri3UnpKS0qhRIy8vr6SkpEopDMorx7Gugq6KNbpUF5G0uLQrm20ns60F+tQQkWotC+9RdtvG\nRTqzIks9i4gk7U8p1J52LrOsazFoUqW5u7vPmzfv2LFjd91115YtW3RdF5HMzMxly5bdf//9\n3t7es2bNquwaAQVpJv/BU17bdvBs0ol9X364bOwj9/y16dN+0ZFbUoq/cdKUO9rMWvFd+7Hz\nt+46nJqVdfrI3q/+84qD5ZfLUIliTZs2LTAwsG/fvosWLUpPT7c3/vzzz+3btz948OCsWbN8\nfHwqt0KgVBUU7DyCH3EzaGd/+LBgY9qZ5ecLBDsXnzbhHuaUI+8Wujvd4fdnjRs37scSxsRC\n/G7pJSJ75n55RauePW/nhXJcS1UxZMgQ+62J27VrFxgY2KBBAz8/vxEjRlgslnXr1oWGhlZ2\ngYBqMhPWPPPMM698fkxEfGo27tp32Cv//mLz882s2efn7kks2j83fc+8PxN867/0+YtjW99a\n38OkiYgtJ97BKm6oQayC1axZ8+uvvw4KCho9erSfn1+DBg2CgoKio6N37tw5Y8aM0aNHV3aB\nQOkq6oida61lnWulnnnj8RU77S22nPPPPfBsoWKWDglLv/Dfzs+vzR+wLh39ssuj05e+s62p\nc9cxeFYbPqCmJX77E6OW/ZjXpOeuePruTclZ5biWKmT8+PF79+6dOHHiLbfc4uvr27Fjx1df\nfXX//v3R0dGVXRqgJH3u3LnPjZ6akJs/wOi/7kgUkVtC3Av2s9k7aCaDpuWmH8q9fLazLSd+\n0eM9RUTEWkx/kRttEKtgUVFRe/bsWbJkSefOnX19fcPDw8ePHx8bG8uNP1FllMsXus7ISdvT\nOdRb04wtO3QfMaRvVD2vgCaP3eJp9qw2OL+PNevUA2G+IhLUKKr34H8N6N3Z12QwGC0zfjht\n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\n"
     },
     "metadata": {
      "image/png": {
       "height": 420,
       "width": 420
      }
     },
     "output_type": "display_data"
    }
   ],
   "source": [
    "###########################################################################\n",
    "# HarvardX: PH125.9x Data Science - Capstone Project\n",
    "# Script: Epidemiological Prediction of COVID-19 Incidence\n",
    "# Author: Lars Böhm, MD | Fixed Version (Bulletproof Join)\n",
    "###########################################################################\n",
    "\n",
    "# 1. Load Required Libraries\n",
    "if(!require(tidyverse)) install.packages(\"tidyverse\")\n",
    "if(!require(data.table)) install.packages(\"data.table\")\n",
    "if(!require(caret)) install.packages(\"caret\")\n",
    "if(!require(randomForest)) install.packages(\"randomForest\")\n",
    "\n",
    "library(tidyverse)\n",
    "library(data.table)\n",
    "library(caret)\n",
    "library(randomForest)\n",
    "\n",
    "# 2. Data Acquisition\n",
    "url_inf <- \"https://raw.githubusercontent.com/larsboehm-data/Harvard_Capstone_COVID/main/covid_de.csv.zip\"\n",
    "url_demo <- \"https://raw.githubusercontent.com/larsboehm-data/Harvard_Capstone_COVID/main/demographics_de.csv\"\n",
    "\n",
    "load_zipped_github_csv <- function(url) {\n",
    "  temp_file <- tempfile(fileext = \".zip\")\n",
    "  download.file(url, temp_file, mode = \"wb\", quiet = TRUE)\n",
    "  inner_file <- unzip(temp_file, list = TRUE)$Name[1]\n",
    "  data <- fread(unzip(temp_file, inner_file))\n",
    "  unlink(temp_file)\n",
    "  return(data)\n",
    "}\n",
    "\n",
    "cat(\"Downloading data from GitHub...\\n\")\n",
    "covid_data <- load_zipped_github_csv(url_inf)\n",
    "demo_data <- fread(url_demo)\n",
    "\n",
    "# 3. Robust Harmonization Function\n",
    "# This ensures that both datasets speak the exact same \"language\"\n",
    "clean_data <- function(df) {\n",
    "  df %>%\n",
    "    mutate(across(c(state, age_group, gender), ~str_trim(tolower(as.character(.))))) %>%\n",
    "    mutate(gender = case_when(\n",
    "      gender %in% c(\"f\", \"w\", \"female\") ~ \"female\",\n",
    "      gender %in% c(\"m\", \"male\") ~ \"male\",\n",
    "      TRUE ~ gender\n",
    "    ))\n",
    "}\n",
    "\n",
    "cat(\"Harmonizing datasets...\\n\")\n",
    "cases_prep <- clean_data(covid_data) %>%\n",
    "  group_by(state, gender, age_group) %>%\n",
    "  summarise(total_cases = sum(cases), .groups = \"drop\")\n",
    "\n",
    "demo_prep <- clean_data(demo_data)\n",
    "\n",
    "# 4. Merging\n",
    "final_df <- cases_prep %>%\n",
    "  inner_join(demo_prep, by = c(\"state\", \"gender\", \"age_group\")) %>%\n",
    "  mutate(incidence = (total_cases / population) * 100000) %>%\n",
    "  filter(!is.na(incidence)) %>%\n",
    "  mutate_if(is.character, as.factor)\n",
    "\n",
    "cat(\"Final dataset rows:\", nrow(final_df), \"\\n\")\n",
    "\n",
    "# 5. Machine Learning\n",
    "if(nrow(final_df) < 10) stop(\"Error: Join failed. Dataset is empty.\")\n",
    "\n",
    "cat(\"Training Random Forest model...\\n\")\n",
    "set.seed(2026)\n",
    "test_index <- createDataPartition(y = final_df$incidence, times = 1, p = 0.2, list = FALSE)\n",
    "train_set <- final_df[-test_index,]\n",
    "test_set <- final_df[test_index,]\n",
    "\n",
    "fit_rf <- randomForest(incidence ~ state + gender + age_group, \n",
    "                       data = train_set, ntree = 100, importance = TRUE)\n",
    "\n",
    "# 6. Results\n",
    "predictions <- predict(fit_rf, test_set)\n",
    "rmse_val <- sqrt(mean((test_set$incidence - predictions)^2))\n",
    "\n",
    "cat(\"\\n--------------------------------------------\\n\")\n",
    "cat(\"Final Results Summary\\n\")\n",
    "cat(\"RMSE:\", rmse_val, \"\\n\")\n",
    "cat(\"Mean Incidence:\", mean(final_df$incidence), \"\\n\")\n",
    "cat(\"--------------------------------------------\\n\")\n",
    "\n",
    "varImpPlot(fit_rf, main = \"Predictive Drivers of COVID-19 Incidence\")"
   ]
  }
 ],
 "metadata": {
  "kaggle": {
   "accelerator": "none",
   "dataSources": [],
   "dockerImageVersionId": 31330,
   "isGpuEnabled": false,
   "isInternetEnabled": true,
   "language": "r",
   "sourceType": "notebook"
  },
  "kernelspec": {
   "display_name": "R",
   "language": "R",
   "name": "ir"
  },
  "language_info": {
   "codemirror_mode": "r",
   "file_extension": ".r",
   "mimetype": "text/x-r-source",
   "name": "R",
   "pygments_lexer": "r",
   "version": "4.4.0"
  },
  "papermill": {
   "default_parameters": {},
   "duration": 14.801946,
   "end_time": "2026-05-08T04:06:24.803652",
   "environment_variables": {},
   "exception": null,
   "input_path": "__notebook__.ipynb",
   "output_path": "__notebook__.ipynb",
   "parameters": {},
   "start_time": "2026-05-08T04:06:10.001706",
   "version": "2.6.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
