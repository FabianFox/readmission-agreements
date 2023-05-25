# Return statistics 

# Load packages
if (!require("xfun")) install.packages("xfun")
pkg_attach2("tidyverse", "here", "readxl", "janitor", "countrycode")

# Load data
# ordered to leave - migr_eiordmn
# returned following an order to leave - migr_eirtn

# Return orders
order.df <- get_eurostat("migr_eiord") %>%
  filter(age == "TOTAL", sex == "T",
         !citizen %in% c("ASI", "RNC", "STLS", "TOTAL", "UK_OCT", "UNK"),) %>% # Asia, Recognised non-citizens, Stateless, TOTAL, UK overseas, Unknown
  mutate(across(c("geo", "citizen"), ~countrycode(., origin = "eurostat", "iso3c", 
                                                  custom_match = c("EU27_2020" = "EU27_2020",
                                                                   "XK" = "XKX")))) %>%
  select(-c(sex, unit, age)) %>%
  rename(n_order = values)

# Returned
return.df <- get_eurostat("migr_eirtn") %>%
  filter(age == "TOTAL", sex == "T", c_dest == "TOTAL",
         !citizen %in% c("ASI", "RNC", "STLS", "TOTAL", "UK_OCT", "UNK"),) %>% # Asia, Recognised non-citizens, Stateless, TOTAL, UK overseas, Unknown
  mutate(across(c("geo", "citizen"), ~countrycode(., origin = "eurostat", "iso3c", 
                                                  custom_match = c("EU27_2020" = "EU27_2020",
                                                                   "XK" = "XKX")))) %>%
  select(-c(sex, unit, age, c_dest)) %>%
  rename(n_leave = values)

# Join
return.df <- return.df %>%
  left_join(order.df, by = c("citizen", "geo", "time"))
