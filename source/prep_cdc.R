library(dplyr)
library(readr)

cdc_us <- read_csv(here::here("data", "resources", "cdc_usa_concentrations.csv")) %>%
  filter(variant != "Other") %>%
  filter(week >= "2021-12-04") %>%
  group_by(week, variant) %>%
  summarise(pct = sum(pct, na.rm = TRUE))

write_csv(cdc_us, here::here("data", "cdc_long.csv"))

cdc_us <- tidyr::pivot_wider(cdc_us, names_from = "variant", values_from = "pct")

write_csv(cdc_us, here::here("data", "cdc_wide.csv"))