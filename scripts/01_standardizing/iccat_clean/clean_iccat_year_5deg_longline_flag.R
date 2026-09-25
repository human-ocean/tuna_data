################################################################################
# Clean ICCAT purse seine yearly flag data
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This R script processes raw longline tuna catch and effort data from the
# ICCAT at the 5 degree, yearly level with flag data.
#
################################################################################

# SET UP #######################################################################

## Load packages ---------------------------------------------------------------
library(tidyverse)
library(janitor)

## Load data -------------------------------------------------------------------
iccat <- readRDS("data/raw/iccat/ms_database_all/iccat_database.rds")

t2ce <- iccat$t2ce |> clean_names()
flags <- iccat$Flags |> clean_names()

# Join flag metadata -----------------------------------------------------------

t2ce_flagged <- iccat$t2ce |>
  clean_names() |>
  left_join(
    iccat$Flags |> clean_names(),
    by = "fleet_id"
  ) |>
  rename(flag = flag_code)

## Build function to center lat/lon from SW corner

center_iccat <- function(lat, lon, quad_id) {
  lat_sign <- case_when(
    quad_id %in% c(1, 4) ~  1,   # NE, NW
    quad_id %in% c(2, 3) ~ -1    # SE, SW
  )
  lon_sign <- case_when(
    quad_id %in% c(1, 2) ~  1,   # NE, SE
    quad_id %in% c(3, 4) ~ -1    # SW, NW
  )

  tibble(
    lat = lat_sign * lat + 2.5,
    lon = lon_sign * lon + 2.5
  )
}

# PROCESSING ###################################################################

## Clean data ------------------------------------------------------------------
iccat_year_flag <- t2ce_flagged |>
  filter(
    gear_grp_code == "LL",        # longline only
    square_type_code == "5x5",    # 5° grid
    time_period_id < 13           # monthly rows
  ) |>
  rename(
    year = year_c
  ) |>
  mutate(
    # Center coordinates
    centered = center_iccat(lat, lon, quad_id),
    lat = centered$lat,
    lon = centered$lon,

    rfmo = "iccat",

    # Clean flag codes
    flag = case_when(
      str_starts(flag, "EU-") ~ str_remove(flag, "EU-"),
      flag %in% c("MIX-FIS", "NEI-001") ~ NA_character_,
      TRUE ~ flag
    ),

    # Standardize effort
    effort_hooks = case_when(
      eff1type == "NO.HOOKS" ~ eff1,
      eff2type == "NO.HOOKS" ~ eff2,
      TRUE ~ NA_real_
    ),

    # Convert effort to thousands of hooks
    effort_t_hooks = effort_hooks / 1000,

    # Convert catches depending on catch_unit
    catch_bet_mt = if_else(catch_unit == "kg", bet / 1000, NA_real_),
    catch_alb_mt = if_else(catch_unit == "kg", alb / 1000, NA_real_),
    catch_yft_mt = if_else(catch_unit == "kg", yft / 1000, NA_real_),

    catch_bet_n = if_else(catch_unit == "nr", bet, NA_real_),
    catch_alb_n = if_else(catch_unit == "nr", alb, NA_real_),
    catch_yft_n = if_else(catch_unit == "nr", yft, NA_real_),

    # Totals
    catch_tot_mt = rowSums(across(c(catch_bet_mt, catch_alb_mt, catch_yft_mt)), na.rm = TRUE),
    catch_tot_n  = rowSums(across(c(catch_bet_n, catch_alb_n, catch_yft_n)), na.rm = TRUE)
  ) |>

  # Remove rows where all species are NA or all zero
  filter(
    !if_all(c(catch_bet_mt, catch_alb_mt, catch_yft_mt,
              catch_bet_n, catch_alb_n, catch_yft_n), is.na),
    !if_all(c(catch_bet_mt, catch_alb_mt, catch_yft_mt,
              catch_bet_n, catch_alb_n, catch_yft_n), ~ .x == 0)
  ) |>

  # Year aggregation
  group_by(rfmo, flag, lon, lat, year) |>
  summarise(
    effort_t_hooks = sum(effort_hooks, na.rm = TRUE),

    catch_tot_mt = sum(catch_tot_mt, na.rm = TRUE),
    catch_tot_n  = sum(catch_tot_n,  na.rm = TRUE),

    catch_bet_mt = sum(catch_bet_mt, na.rm = TRUE),
    catch_bet_n  = sum(catch_bet_n,  na.rm = TRUE),

    catch_alb_mt = sum(catch_alb_mt, na.rm = TRUE),
    catch_alb_n  = sum(catch_alb_n,  na.rm = TRUE),

    catch_yft_mt = sum(catch_yft_mt, na.rm = TRUE),
    catch_yft_n  = sum(catch_yft_n,  na.rm = TRUE),

    .groups = "drop"
  ) |>
  arrange(year, lat, lon, flag)

# EXPORT #######################################################################

saveRDS(iccat_year_flag, "data/processed/iccat/iccat_year_5deg_longline_flag.rds")
