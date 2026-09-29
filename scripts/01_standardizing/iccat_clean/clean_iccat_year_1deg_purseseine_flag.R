################################################################################
# Build ICCAT yearly data set
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This R script processes raw purse seine tuna catch and effort data from
# ICCAT into a 1x1 degree yearly resolution.
#
################################################################################

# SET UP #######################################################################

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

# Centering function -----------------------------------------------------------

center_iccat <- function(lat, lon, quad_id) {
  lat_sign <- case_when(
    quad_id %in% c(1, 4) ~  1,
    quad_id %in% c(2, 3) ~ -1
  )
  lon_sign <- case_when(
    quad_id %in% c(1, 2) ~  1,
    quad_id %in% c(3, 4) ~ -1
  )

  tibble(
    lat = lat_sign * (lat + 0.5),
    lon = lon_sign * (lon + 0.5)
  )
}

# PROCESSING ###################################################################

iccat_year_flag <- t2ce_flagged |>
  filter(
    gear_grp_code == "PS",
    square_type_code == "1x1",
    d_set_type_id == ".w",
    time_period_id < 13
  ) |>
  rename(
    year = year_c,
    month = time_period_id,
    catch_skj = skj,
    catch_alb = alb,
    catch_bet = bet,
    catch_yft = yft
  ) |>
  mutate(
    centered = center_iccat(lat, lon, quad_id),
    lat = centered$lat,
    lon = centered$lon,

    rfmo = "iccat",

    flag = case_when(
      # EU composite codes = keep the country after "EU-"
      str_starts(flag, "EU-") ~ str_remove(flag, "EU-"),

      # Mixed fleet codes to NA
      flag %in% c("MIX-FIS", "NEI-001") ~ NA_character_,

      # Everything else is already ISO-3
      TRUE ~ flag
    ),

    catch_skj = catch_skj / 1000,
    catch_alb = catch_alb / 1000,
    catch_bet = catch_bet / 1000,
    catch_yft = catch_yft / 1000,

    effort_set = case_when(
      eff1type == "NO.SETS" ~ eff1,
      eff2type == "NO.SETS" ~ eff2,
      TRUE ~ NA_real_
    ),
    effort_day = case_when(
      eff1type == "D.FISH" ~ eff1,
      eff2type == "D.FISH" ~ eff2,
      TRUE ~ NA_real_
    ),

    catch_tot = rowSums(across(c(catch_skj, catch_alb, catch_bet, catch_yft)), na.rm = TRUE)
  ) |>
  filter(
    !if_all(c(catch_skj, catch_alb, catch_bet, catch_yft), is.na),
    !if_all(c(catch_skj, catch_alb, catch_bet, catch_yft), ~ .x == 0)
  ) |>
  group_by(rfmo, flag, lon, lat, year) |>
  summarise(
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

saveRDS(iccat_year_flag, "data/processed/iccat/iccat_year_1deg_purseseine_flag.rds")
