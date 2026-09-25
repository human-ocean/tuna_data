################################################################################
# Clean IOTC purse seine data
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jxv893@miami.edu
#
# This R script processes prepared purse seine tuna catch and effort data from
# the IOTC at the month, 1 degree level, aggregated across flags.
#
# IOTC reports purse seine effort in several units. Only sets (`SETS`) and
# fishing days (`FDAYS`) match the units used by the other RFMOs, so those are
# the only ones retained. Hours, standardized hours, trips and days at sea are
# not comparable and are left as NA. Roughly two thirds of IOTC purse seine
# catch, mostly before 2009, therefore has no effort reported.
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

purseseine_prepped <- readRDS(
  "data/raw/iotc/IOTC-DATASETS-2026-08-13-CE-1952-2025/iotc_month_1deg_purseseine_prepped.rds"
)

# PROCESSING ###################################################################

iotc_month_1deg_purseseine_clean <- purseseine_prepped |>

  # Aggregate across flags
  group_by(lon, lat, year, month) |>
  summarise(
    sets = sum_or_na(sets),
    fdays = sum_or_na(fdays),
    skj_mt = sum_or_na(skj_mt),
    alb_mt = sum_or_na(alb_mt),
    bet_mt = sum_or_na(bet_mt),
    yft_mt = sum_or_na(yft_mt),
    .groups = "drop"
  ) |>

  mutate(
    # Effort in sets and fishing days
    effort_set = sets,
    effort_day = fdays,

    # Species specific catch in mt
    catch_skj = skj_mt,
    catch_alb = alb_mt,
    catch_bet = bet_mt,
    catch_yft = yft_mt,

    # Total catch across the four species
    catch_tot = rowSums(across(c(catch_skj, catch_alb, catch_bet, catch_yft)), na.rm = TRUE),

    rfmo = "iotc"
  ) |>

  # Remove all NA or all 0 species rows
  filter(
    !if_all(c(catch_skj, catch_alb, catch_bet, catch_yft), is.na),
    !if_all(c(catch_skj, catch_alb, catch_bet, catch_yft), ~ .x == 0)
  ) |>

  arrange(year, month) |>

  select(
    rfmo, lon, lat, year, month,
    effort_set, effort_day,
    catch_tot, catch_skj,
    catch_alb, catch_bet, catch_yft
  )

# EXPORT #######################################################################

saveRDS(
  iotc_month_1deg_purseseine_clean,
  "data/processed/iotc/iotc_month_1deg_purseseine.rds"
)
