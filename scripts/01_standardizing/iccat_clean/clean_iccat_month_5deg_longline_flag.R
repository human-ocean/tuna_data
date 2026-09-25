################################################################################
# Clean ICCAT purse seine monthly data
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This R script processes raw longline tuna catch and effort data from the
# ICCAT at the 5 degree, monthly level with flag data.
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
    lat = lat_sign * (lat + 2.5),
    lon = lon_sign * (lon + 2.5)
  )
}

# PROCESSING ###################################################################

## Clean data ------------------------------------------------------------------
iccat_month_flag <- t2ce_flagged |>
  filter(
    gear_grp_code == "LL",        # longline only
    square_type_code == "5x5",    # 5° grid
    time_period_id < 13           # monthly only
  ) |>
  rename(
    year  = year_c,
    month = time_period_id
  ) |>

  # Center coordinates
  mutate(
    centered = center_iccat(lat, lon, quad_id),
    lat = centered$lat,
    lon = centered$lon
  ) |>

  # Clean flag codes
  mutate(
    flag = case_when(
      # EU composite codes = keep the country after "EU-"
      str_starts(flag, "EU-") ~ str_remove(flag, "EU-"),

      # Mixed fleet codes to NA
      flag %in% c("MIX-FIS", "NEI-001") ~ NA_character_,

      # Everything else is already ISO-3
      TRUE ~ flag
    )
  ) |>

  # Standardize effort
  mutate(
    effort_hooks = case_when(
      eff1type == "NO.HOOKS" ~ eff1,
      eff2type == "NO.HOOKS" ~ eff2,
      TRUE ~ NA_real_
    )
  ) |>

  # Convert effort to thousands of hooks
  mutate(
    effort_t_hooks = effort_hooks / 1000
  ) |>

  # Convert catches depending on catch_unit
  mutate(
    # Metric tons (kg → mt)
    catch_bet_mt = if_else(catch_unit == "kg", bet / 1000, NA_real_),
    catch_alb_mt = if_else(catch_unit == "kg", alb / 1000, NA_real_),
    catch_yft_mt = if_else(catch_unit == "kg", yft / 1000, NA_real_),

    # Numbers
    catch_bet_n = if_else(catch_unit == "nr", bet, NA_real_),
    catch_alb_n = if_else(catch_unit == "nr", alb, NA_real_),
    catch_yft_n = if_else(catch_unit == "nr", yft, NA_real_),

    # Totals
    catch_tot_mt = rowSums(across(c(catch_bet_mt, catch_alb_mt, catch_yft_mt)), na.rm = TRUE),
    catch_tot_n = rowSums(across(c(catch_bet_n, catch_alb_n, catch_yft_n)), na.rm = TRUE),

    rfmo = "iccat"
  ) |>

  # Remove rows where all species are NA or all zero
  filter(
    !if_all(c(catch_bet_mt, catch_alb_mt, catch_yft_mt,
              catch_bet_n, catch_alb_n, catch_yft_n), is.na),
    !if_all(c(catch_bet_mt, catch_alb_mt, catch_yft_mt,
              catch_bet_n, catch_alb_n, catch_yft_n), ~ .x == 0)
  ) |>

  select(
    rfmo, flag, lon, lat, year, month,
    effort_t_hooks,
    catch_tot_mt, catch_tot_n,
    catch_bet_mt, catch_bet_n,
    catch_alb_mt, catch_alb_n,
    catch_yft_mt, catch_yft_n
  )

## EXPORT ######################################################################
saveRDS(iccat_month_flag,"data/processed/iccat/iccat_month_5deg_longline_flag.rds")
