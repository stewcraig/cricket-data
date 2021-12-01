# Load in and clean cricket data pulled from
#
# https://cricsheet.org/downloads/tests_json.zip

library(tidyverse)
library(here)
library(jsonlite)
library(janitor)


# Source files ------------------------------------------------------------

source(here("R/helpers.R"))

# Download data -----------------------------------------------------------

url <- "https://cricsheet.org/downloads/tests_json.zip"
tests_zip <- download_data(url, "data")

# Unzip files -------------------------------------------------------------

json_data_dir <- here("data/test_json")
unzip(tests_zip, exdir = json_data_dir)

# Load files --------------------------------------------------------------

files <- list.files(json_data_dir, full.name = TRUE, pattern = ".json")

# Name files
match_id <- str_remove(basename(files), ".json")
names(files) <- match_id

# Load data
data_raw <- map(files, fromJSON)

# Clean data --------------------------------------------------------------

data_cleaned <- map(data_raw, clean_data)

