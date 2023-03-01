Data Skills 06 - Data Wrangling with Time Series Data - Complete
================
Christopher Prener, Ph.D.
(March 01, 2023)

## Dependencies

This notebook requires two packages from the `tidyverse` as well as two
additional packages:

``` r
# tidyverse packages
library(dplyr)     # data wrangling
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(readr)     # read and write csv files
library(tidyr)     # pivot

# manage file paths
library(here)      # manage file paths
```

    ## here() starts at /Users/prenec/Documents/GitHub/data_skills/data-skills-06

## Load Data

For this session and our future sessions this spring, we’ll focus on two
sets of data - COVID cases and mortality from the New York Times and
SARS-CoV-2 variants from the CDC. For today, we’ll start by using
pre-cleaned versions of both. First, we’ll load the COVID case and
mortality data:

``` r
## nyt covid data
nyt_wide <- read_csv(here("data", "nyt_wide.csv"))
```

    ## Rows: 1058 Columns: 5
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## dbl  (4): cases, cases_avg7_pc, deaths, deaths_avg7_pc
    ## date (1): date
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
nyt_long <- read_csv(here("data", "nyt_long.csv"))
```

    ## Rows: 4232 Columns: 3
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr  (1): measure
    ## dbl  (1): value
    ## date (1): date
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
## cdc variant data
cdc_wide <- read_csv(here("data", "cdc_wide.csv"))
```

    ## Rows: 39 Columns: 8
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## dbl  (7): BA.1, BA.2, BA.2.12, BA.2.75, BA.4, BA.5, Delta
    ## date (1): week
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
cdc_long <- read_csv(here("data", "cdc_long.csv"))
```

    ## Rows: 273 Columns: 3
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr  (1): variant
    ## dbl  (1): pct
    ## date (1): week
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

Next, you write a similar statement to load the complete, raw CDC
national variant data, which is stored in `cdc_usa.csv` in the `data`
folder:

``` r
cdc <- read_csv(here("data", "cdc_usa.csv"))
```

    ## Rows: 53858 Columns: 10
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr  (6): usa_or_hhsregion, variant, share_lo, count_lt10, modeltype, time_i...
    ## dbl  (2): share, share_hi
    ## dttm (2): week_ending, creation_date
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

## Pivoting from Wide to Long

Time series data are often shipped in “wide” format, where each row is a
unique date and different data points are stored in columns. This is a
typical organizational strategy for spreadsheets, but (1) `ggplot2` does
not plot time series data in “wide” format and (2) I’ve found it to be a
less efficient format to work with for data tasks.

The `nyt_wide` data are an example of this format. Each row is a single
date, and there are columns for the numbers of new cases and deaths as
well as their 7-day average per capita rates.

``` r
nyt_wide
```

    ## # A tibble: 1,058 × 5
    ##    date       cases cases_avg7_pc deaths deaths_avg7_pc
    ##    <date>     <dbl>         <dbl>  <dbl>          <dbl>
    ##  1 2020-01-21     1   NA               0             NA
    ##  2 2020-01-22     1   NA               0             NA
    ##  3 2020-01-23     1   NA               0             NA
    ##  4 2020-01-24     2   NA               0             NA
    ##  5 2020-01-25     3   NA               0             NA
    ##  6 2020-01-26     5   NA               0             NA
    ##  7 2020-01-27     5   NA               0             NA
    ##  8 2020-01-28     5    0.00000173      0              0
    ##  9 2020-01-29     5    0.00000173      0              0
    ## 10 2020-01-30     6    0.00000217      0              0
    ## # … with 1,048 more rows

Similarly, the `cdc_wide` data have one row per date, and columns for
each variant:

``` r
cdc_wide
```

    ## # A tibble: 39 × 8
    ##    week        BA.1  BA.2 BA.2.12 BA.2.75  BA.4  BA.5 Delta
    ##    <date>     <dbl> <dbl>   <dbl>   <dbl> <dbl> <dbl> <dbl>
    ##  1 2021-12-04   0.8   0         0       0     0     0  98.9
    ##  2 2021-12-11   7.9   0         0       0     0     0  91.8
    ##  3 2021-12-18  38     0         0       0     0     0  61.6
    ##  4 2021-12-25  73.5   0         0       0     0     0  25.8
    ##  5 2022-01-01  89     0         0       0     0     0  10.2
    ##  6 2022-01-08  95.1   0.1       0       0     0     0   4.5
    ##  7 2022-01-15  97.8   0.2       0       0     0     0   1.9
    ##  8 2022-01-22  98.6   0.4       0       0     0     0   0.8
    ##  9 2022-01-29  98.7   0.8       0       0     0     0   0.5
    ## 10 2022-02-05  98.2   1         0       0     0     0   0.7
    ## # … with 29 more rows

For plotting, we need to transform our data from “wide” to “long.” We
can use the `tidyr` package’s `pivot_longer()` function to do this. The
key arguments we need to fill in are: \* `cols` - takes a vector of
columns to pivot to long \* `names_to` - the name of the new column
where column names from the source data (listed in `cols`) are deposited
\* `values_to` - the name of the new column where values from the source
data (listed in `cols`) are deposited

I prefer to implement `pivot_longer()` in a pipe, where columns are
removed before implementing the function:

``` r
nyt_wide %>%
  select(date, cases_avg7_pc, deaths_avg7_pc) %>%
  pivot_longer(cols = c("cases_avg7_pc", "deaths_avg7_pc"), names_to = "measure", values_to = "value")
```

    ## # A tibble: 2,116 × 3
    ##    date       measure        value
    ##    <date>     <chr>          <dbl>
    ##  1 2020-01-21 cases_avg7_pc     NA
    ##  2 2020-01-21 deaths_avg7_pc    NA
    ##  3 2020-01-22 cases_avg7_pc     NA
    ##  4 2020-01-22 deaths_avg7_pc    NA
    ##  5 2020-01-23 cases_avg7_pc     NA
    ##  6 2020-01-23 deaths_avg7_pc    NA
    ##  7 2020-01-24 cases_avg7_pc     NA
    ##  8 2020-01-24 deaths_avg7_pc    NA
    ##  9 2020-01-25 cases_avg7_pc     NA
    ## 10 2020-01-25 deaths_avg7_pc    NA
    ## # … with 2,106 more rows

Listing column names can be impractical, so one strategy is to create a
vector of column ahead of time. The `names()` function will return all
of the column names, and we can add `[-1]` to remove the first column,
`date`, because it should be omitted in the pivot. When the vector of
names is included in `pivot_longer()`, it needs to be wrapped in a
helper function called `all_of()`:

``` r
## create names vector
names <- names(nyt_wide)[-1]

## pivot
nyt_pivot <- pivot_longer(nyt_wide, cols = all_of(names), names_to = "measure", values_to = "value")

## print
nyt_pivot
```

    ## # A tibble: 4,232 × 3
    ##    date       measure        value
    ##    <date>     <chr>          <dbl>
    ##  1 2020-01-21 cases              1
    ##  2 2020-01-21 cases_avg7_pc     NA
    ##  3 2020-01-21 deaths             0
    ##  4 2020-01-21 deaths_avg7_pc    NA
    ##  5 2020-01-22 cases              1
    ##  6 2020-01-22 cases_avg7_pc     NA
    ##  7 2020-01-22 deaths             0
    ##  8 2020-01-22 deaths_avg7_pc    NA
    ##  9 2020-01-23 cases              1
    ## 10 2020-01-23 cases_avg7_pc     NA
    ## # … with 4,222 more rows

One final point to raise is that you may want to clean up the `measure`
values afterward. For example:

``` r
mutate(nyt_pivot, measure = case_when(
  measure == "cases_avg7_pc" ~ "avg cases per capita",
  measure == "deaths_avg7_pc" ~ "avg deaths per capita",
  TRUE ~ measure
))
```

    ## # A tibble: 4,232 × 3
    ##    date       measure               value
    ##    <date>     <chr>                 <dbl>
    ##  1 2020-01-21 cases                     1
    ##  2 2020-01-21 avg cases per capita     NA
    ##  3 2020-01-21 deaths                    0
    ##  4 2020-01-21 avg deaths per capita    NA
    ##  5 2020-01-22 cases                     1
    ##  6 2020-01-22 avg cases per capita     NA
    ##  7 2020-01-22 deaths                    0
    ##  8 2020-01-22 avg deaths per capita    NA
    ##  9 2020-01-23 cases                     1
    ## 10 2020-01-23 avg cases per capita     NA
    ## # … with 4,222 more rows

Now, try implementing a this on the `cdc_wide` data. The variable names
from `cdc_wide` can be stored in the name `names` object we created
above. Name your new, pivoted object `cdc_pivot`:

``` r
## create names vector
names <- names(cdc_wide)[-1]

## pivot
cdc_pivot <- pivot_longer(cdc_wide, cols = all_of(names), names_to = "measure", values_to = "value")

## print
cdc_pivot
```

    ## # A tibble: 273 × 3
    ##    week       measure value
    ##    <date>     <chr>   <dbl>
    ##  1 2021-12-04 BA.1      0.8
    ##  2 2021-12-04 BA.2      0  
    ##  3 2021-12-04 BA.2.12   0  
    ##  4 2021-12-04 BA.2.75   0  
    ##  5 2021-12-04 BA.4      0  
    ##  6 2021-12-04 BA.5      0  
    ##  7 2021-12-04 Delta    98.9
    ##  8 2021-12-11 BA.1      7.9
    ##  9 2021-12-11 BA.2      0  
    ## 10 2021-12-11 BA.2.12   0  
    ## # … with 263 more rows

## Pivoting from Long to Wide

We can also go the opposite way, from “long” data to “wide” data. I find
this to be helpful for constructing specific types of output, especially
when I know the data will be viewed in Microsoft Excel. We’ll use the
`pivot_wider()` function from the `tidyr` package. The key arguments we
need to fill in are: \* `id_cols` - the column name in the source data
that should uniquely identify rows in the transformed data \*
`names_from` - the name of the source data column whose values should
become column names in the transformed data \* `values_from` - the name
of the source data column whose values should fill in values for the
transformed data’s new columns

``` r
nyt_long %>%
  pivot_wider(id_cols = "date", names_from = "measure", values_from = "value")
```

    ## # A tibble: 1,058 × 5
    ##    date       cases cases_avg7_pc deaths deaths_avg7_pc
    ##    <date>     <dbl>         <dbl>  <dbl>          <dbl>
    ##  1 2020-01-21     1   NA               0             NA
    ##  2 2020-01-22     1   NA               0             NA
    ##  3 2020-01-23     1   NA               0             NA
    ##  4 2020-01-24     2   NA               0             NA
    ##  5 2020-01-25     3   NA               0             NA
    ##  6 2020-01-26     5   NA               0             NA
    ##  7 2020-01-27     5   NA               0             NA
    ##  8 2020-01-28     5    0.00000173      0              0
    ##  9 2020-01-29     5    0.00000173      0              0
    ## 10 2020-01-30     6    0.00000217      0              0
    ## # … with 1,048 more rows

One key trick is to make sure the values in `measure` are appropriate
for variable names ahead of time. They should be short, readable, and
without spaces or special characters. Use `mutate()` as needed to tidy
them up before privoting!

Now, you try - pivot the `cdc_long` data to wide. If you decide to write
your changes to an object, name it `cdc_pivot`:

``` r
cdc_long %>%
  pivot_wider(id_cols = "week", names_from = "variant", values_from = "pct")
```

    ## # A tibble: 39 × 8
    ##    week        BA.1  BA.2 BA.2.12 BA.2.75  BA.4  BA.5 Delta
    ##    <date>     <dbl> <dbl>   <dbl>   <dbl> <dbl> <dbl> <dbl>
    ##  1 2021-12-04   0.8   0         0       0     0     0  98.9
    ##  2 2021-12-11   7.9   0         0       0     0     0  91.8
    ##  3 2021-12-18  38     0         0       0     0     0  61.6
    ##  4 2021-12-25  73.5   0         0       0     0     0  25.8
    ##  5 2022-01-01  89     0         0       0     0     0  10.2
    ##  6 2022-01-08  95.1   0.1       0       0     0     0   4.5
    ##  7 2022-01-15  97.8   0.2       0       0     0     0   1.9
    ##  8 2022-01-22  98.6   0.4       0       0     0     0   0.8
    ##  9 2022-01-29  98.7   0.8       0       0     0     0   0.5
    ## 10 2022-02-05  98.2   1         0       0     0     0   0.7
    ## # … with 29 more rows

## Clean-up

Before we move on, let’s get rid of most of the objects we’ve created:

``` r
rm(cdc_long, cdc_wide, cdc_pivot, nyt_long, nyt_wide, nyt_pivot, names)
```

## Exploring the CDC Data

Our goal for the rest of the semester’s session is to write functions to
make our work with the CDC variant data reproducible. We’ll work on
iterating with those functions so that we can create a series of plots,
updated weekly, easy to create.

Today, we’ll work on writing code that deals with some of the challenges
that the CDC data come with. To help us get started, I’ve created a
lookup table that takes SARS-CoV-2 pango values and applies WHO and
variant labels to make them a bit more analytically friendly. These will
allow us to crosswalk those pango values once the data are cleaned.
Notice how I am using `tibble()` to create the initial data frame,
`rep()` to reduce the amount of text I need to write for the `who`
vector, and `mutate()` combined with `case_when()` to create the
`variant` vector.

``` r
variants <- tibble(
 pango = c("B.1.1.7", "B.1.351", "P.1", "B.1.617.2", "AY.1", "AY.2", "AY.3",
           "B.1.617.1", "B.1.427", "B.1.429", "B.1.525", "B.1.526", "C.37",
           "B.1.621", "B.1.621.1", "B.1.1.529", "BA.1", "BA.1.1", "BA.2", 
           "BA.2.12.1", "BA.2.75", "BA.2.75.2", "BA.4", "BA.4.6", "BA.5",
           "BA.5.2.6", "BQ.1", "BQ.1.1", "XBB", "XBB.1.5",
           "A.2.5", "B.1.1.194", "B.1.617.3", "B.1.626", "B.1.628",
           "B.1.637", "BF.11", "BF.7", "BN.1", "CH.1.1", "Other"),
 who = c("Alpha", "Beta", "Gamma", rep("Delta", 4), 
         "Kappa", rep("Epsilon", 2), "Eta", "Iota", "Lambda",
         rep("Mu", 2), rep("Omicron", 15), rep("Other", 11))
 )

variants <- variants %>%
  mutate(variant = case_when(
    pango %in% c("BA.1", "BA.1.1", "B.1.1.529") ~ "BA.1",
    pango == "BA.2" ~ "BA.2",
    pango %in% c("BA.2.75", "BA.2.75.2") ~ "BA.2.75",
    pango %in% c("BA.2.12.1") ~ "BA.2.12",
    pango %in% c("BA.4", "BA.4.6") ~ "BA.4",
    pango %in% c("BA.5", "BA.5.2.6") ~ "BA.5",
    pango %in% c("BQ.1", "BQ.1.1") ~ "BQ.1",
    pango %in% c("XBB", "XBB.1.5") ~ "XBB",
    TRUE ~ who
  ))
```

With those created, let’s start by taking a look at the CDC data using
the `View()` functionality, and making a to-do list of what we might
what to change:

- Variable names could be improved
- Observations are out of order
- We only want the finalized estimates and now the NowCast values, so we
  should focues on the `weighted` values for `modeltype`
- We only want the `weekly` time interval values
- We should convert the week data to a date instead of a date-time stamp
- There are multiple, revised entries for some dates - we should keep
  just the most recent one!
- We have the most detailed values in the variant column - these are
  pango values that could be consolidated into more general buckets like
  `"Delta"` and `"BA.1"`
- We don’t need all of the columns
- The percentage values are string, and could be rounded

Now, let’s work on implementing some of those changes:

``` r
## initial tidying
cdc %>%
  rename(region = usa_or_hhsregion, 
         week = week_ending, 
         pango = variant,
         pct = share, 
         pct_ci_lo = share_lo, 
         pct_ci_hi = share_hi) %>%
  arrange(week, pango, creation_date) %>%
  filter(modeltype == "weighted" & time_interval == "weekly") %>%
  mutate(week = as.Date(week)) -> cdc_clean

## clean up multiple entries
cdc_clean %>%
  group_by(week, pango) %>%
  filter(creation_date == max(creation_date)) %>%
  ungroup() -> cdc_clean
  
## create who labels out of pangos
cdc_clean <- left_join(cdc_clean, variants, by = "pango")

## remove columns
cdc_clean <- select(cdc_clean, region, week, pango, who, variant, 
                    pct, pct_ci_lo, pct_ci_hi)
```

We have one task left, which is to tidy up our percentage column values.
To do this, we’re going to use a custom function - this allows us to get
a preview of where we are headed next time, which is to create functions
ourselves. We use the `function()` function, and specify that we have
one argument, `x`. This will be substituted in the next code chunk for a
column name. We then apply four changes to `x` inside the function,
ultimately returning a modified function that is numeric, has `NA`
values handled appropriately, is rounded, and has been multiplied by
100.

``` r
clean_pcts <- function(x){
  
  ## tidy
  ### convert "NULL" to NA, then enforce numeric requirement
  x <- ifelse(x == "NULL", NA, x)
  x <- as.numeric(x)
  
  ### round to 4 decimal places, and then multiple to convert from 
  ### proportion to percentages
  x <- round(x, digits = 4)
  x <- x*100
  
  ## return output
  return(x)
  
}
```

Finally, we can apply our function over three columns using `across()`.
We specify that we want to iterate over three columns, and apply
`clean_pcts()`. Notice how we use the `~` to tell `across()` our
function may have arguments, and the `.x` syntax to designate where
individual column names should be passed to our function.

``` r
## clean up percentages
cdc_clean <- mutate(cdc_clean, across(.cols = c(pct, pct_ci_lo, pct_ci_hi), 
                                      .fns = ~clean_pcts(x = .x)))
```

This process also introduces iteration - in this case, efficiently
applying code over three columns!

This code will become the basis for writing a function in our next
session that packages up our code for reuse week after week.
