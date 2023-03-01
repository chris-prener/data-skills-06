## prep cdc data for cleaning examples

library(dplyr)

cdc <- RSocrata::read.socrata("https://data.cdc.gov/resource/jr58-6ysp.json") %>%
  filter(usa_or_hhsregion == "USA")

readr::write_csv(cdc, "data/cdc_usa.csv")

