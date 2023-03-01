library(dplyr)
library(readr)
library(tidyr)

nyt <- read_csv(here::here("data", "resources", "nyt_usa_covid_raw.csv"))

nyt <- select(nyt, date, cases, cases_avg7_pc, deaths, deaths_avg7_pc)

nyt %>%
  pivot_longer(cols = c(cases, cases_avg7_pc, deaths, deaths_avg7_pc), 
               names_to = "measure", values_to = "value") -> nyt_long

write_csv(nyt, here::here("data", "nyt_wide.csv"))
write_csv(nyt_long, here::here("data", "nyt_long.csv"))
