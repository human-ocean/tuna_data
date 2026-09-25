################################################################################
# Aggregate IOTC purse seine data to yearly
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jxv893@miami.edu
#
# This R script aggregates the cleaned monthly IOTC purse seine data at the
# 1 degree level to a yearly resolution.
#
################################################################################

# SET UP #######################################################################

## Load packages ---------------------------------------------------------------
library(tidyverse)

## Build function to sum without turning all-NA groups into zero ---------------

### `sum(x, na.rm = TRUE)` returns 0 when every value is missing, which would
### report "not reported" as "zero". The project stores missing values as NA.

sum_or_na <- function(x) {
  if (all(is.na(x))) NA_real_ else sum(x, na.rm = TRUE)
}

## Load data -------------------------------------------------------------------

ps_month <- readRDS("data/processed/iotc/iotc_month_1deg_purseseine.rds")

# PROCESSING ###################################################################

ps_year <- ps_month |>

  # Group by cell and year
  group_by(rfmo, lon, lat, year) |>

  # Sum effort and catch across months
  summarise(
    effort_set = sum_or_na(effort_set),
    effort_day = sum_or_na(effort_day),
    catch_tot = sum_or_na(catch_tot),
    catch_skj = sum_or_na(catch_skj),
    catch_alb = sum_or_na(catch_alb),
    catch_bet = sum_or_na(catch_bet),
    catch_yft = sum_or_na(catch_yft),
    .groups = "drop"
  ) |>

  filter(
    !if_all(c(catch_skj, catch_alb, catch_bet, catch_yft), is.na),
    !if_all(c(catch_skj, catch_alb, catch_bet, catch_yft), ~ .x == 0)
  ) |>

  arrange(year, lat, lon) |>

  select(
    rfmo, lon, lat, year,
    effort_set, effort_day,
    catch_tot, catch_skj,
    catch_alb, catch_bet, catch_yft
  )

# EXPORT #######################################################################

saveRDS(ps_year, "data/processed/iotc/iotc_year_1deg_purseseine.rds")
