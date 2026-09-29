################################################################################
# Aggregate IOTC purse seine data to yearly
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jxv893@miami.edu
#
# This R script aggregates prepared monthly IOTC purse seine data at the
# 1 degree level with flag data to a yearly resolution. There is no monthly
# purse seine dataset with flag data, so the cleaning steps are repeated here
# before aggregating.
#
# IOTC reports purse seine effort in several units. Only sets (`SETS`) and
# fishing days (`FDAYS`) match the units used by the other RFMOs, so those are
# the only ones retained. Hours, standardized hours, trips and days at sea are
# not comparable and are left as NA.
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

ps_month <- purseseine_prepped |>
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
  )

ps_year <- ps_month |>

  # Group by cell, flag, and year
  group_by(rfmo, flag, lon, lat, year) |>

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

  arrange(year, lat, lon, flag) |>

  select(
    rfmo, flag, lon, lat, year,
    effort_set, effort_day,
    catch_tot, catch_skj,
    catch_alb, catch_bet, catch_yft
  )

# EXPORT #######################################################################

saveRDS(ps_year, "data/processed/iotc/iotc_year_1deg_purseseine_flag.rds")
