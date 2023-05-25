# Readmission agreements

# Load packages
if (!require("xfun")) install.packages("xfun")
pkg_attach2("tidyverse", "here", "readxl", "janitor", "countrycode")

# Load data
# Path
path <- here("data", "Dataset Inventory of the Bilateral Agreements linked to Readmission.xlsx")

# Load
ra.orig <- path %>% 
  excel_sheets() %>% 
  # remove metadata sheet
  .[-1] %>%
  set_names() %>% 
  map_df(~ read_excel(path = path, sheet = .x, range = cell_cols("A:B"),
                      col_names = c("countryB", "agreement")), .id = "countryA")

# Clean data
ra.df <- ra.orig %>%
  filter(if_all(everything(), ~!is.na(.)),
         !countryB %in% c("Countries", "Third countries"))

# Separate rows cointaining multiple agreements
ra.test <- ra.df %>%
  separate_longer_delim(agreement, ";") %>%
  separate_longer_delim(agreement, "+") %>%
  mutate(agreement = str_squish(agreement),
         across(starts_with("country"), ~str_to_title(.)),
         across(starts_with("country"), ~countrycode(., "country.name.en", "iso3c", 
                                                     custom_match = c("Denmak" = "DNK",
                                                                      "European Union" = "EU",
                                                                      "Fghanistan" = "AFG",
                                                                      "Kazahkstan" = "KAZ",
                                                                      "Khazakstan" = "KAZ",
                                                                      "Kosovo" = "XKX",
                                                                      "Somaliland" = "SOM")), # likely Somalia but check
                .names = "{.col}_iso3c"))
