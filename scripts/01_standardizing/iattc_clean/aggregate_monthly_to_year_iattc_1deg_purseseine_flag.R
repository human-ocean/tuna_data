################################################################################
# Clean IATTC purse seine monthly data
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This R script processes raw purse seine tuna catch and effort data from the
# IATTC at a 1 degree monthly resolution with flag ID to the yearly level.
#
# Note: Decimals appear in earlier reporting.
#
################################################################################

# SET UP #######################################################################

## Load packages ---------------------------------------------------------------
library(tidyverse)
library(janitor)

## Load data -------------------------------------------------------------------
ps_tuna <- read_csv("data/raw/iattc/month_1deg_purseseine/month_1deg_purseseine_flag.csv") |>
  clean_names()

## Clean data ------------------------------------------------------------------
ps_tuna_clean <- ps_tuna |>
  rename(
    year = year,
    month = month,
    lat = lat_c1,
    lon = lon_c1,
    effort_set = num_sets,
    catch_skj = skj,
    catch_alb = alb,
    catch_bet = bet,
    catch_yft = yft,
  ) |>
  mutate(
    effort_day = NA_real_,  # IATTC does not report effort in days
    rfmo = "iattc",
    # "Other" to NA
    flag = case_when(
      flag == "Other" ~ NA_character_,
      TRUE ~ flag
    )
  ) |>
  # Total catch across the three species (sums if NAs exist)
  mutate(
    catch_tot = rowSums(across(c(catch_skj, catch_alb, catch_bet, catch_yft)), na.rm = TRUE)
  ) |>
  # Remove all NA or all 0 species rows
  filter(
    !if_all(c(catch_skj, catch_alb, catch_bet, catch_yft), is.na),        # remove rows where all are NA
    !if_all(c(catch_skj, catch_alb, catch_bet, catch_yft), ~ .x == 0)    # remove rows where all are 0
  ) |>
  select(
    rfmo, flag, lon, lat, year, month,
    effort_set, effort_day,
    catch_tot, catch_skj, catch_alb, catch_bet, catch_yft
  )

iattc_yearly_flag <- ps_tuna_clean |>
  group_by(rfmo, flag, lon, lat, year) |>
  summarize(
    effort_set = sum(effort_set, na.rm = TRUE),
    effort_day = sum(effort_day, na.rm = TRUE),
    catch_tot  = sum(catch_tot,  na.rm = TRUE),
    catch_skj  = sum(catch_skj,  na.rm = TRUE),
    catch_alb  = sum(catch_alb,  na.rm = TRUE),
    catch_bet  = sum(catch_bet,  na.rm = TRUE),
    catch_yft  = sum(catch_yft,  na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(year, lat, lon, flag)


# EXPORT #######################################################################

saveRDS(iattc_yearly_flag, "data/processed/iattc/iattc_year_1deg_purseseine_flag.rds")
