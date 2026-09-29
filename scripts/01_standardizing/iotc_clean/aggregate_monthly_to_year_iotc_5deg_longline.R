################################################################################
# Aggregate IOTC longline data to yearly
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jxv893@miami.edu
#
# This R script aggregates the cleaned monthly IOTC longline data at the
# 5 degree level to a yearly resolution.
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

ll_month <- readRDS("data/processed/iotc/iotc_month_5deg_longline.rds")

# PROCESSING ###################################################################

ll_year <- ll_month |>

  # Group by cell and year
  group_by(rfmo, lon, lat, year) |>

  # Sum effort and catch across months
  summarise(
    effort_t_hooks = sum_or_na(effort_t_hooks),
    catch_tot_mt = sum_or_na(catch_tot_mt),
    catch_tot_n = sum_or_na(catch_tot_n),
    catch_bet_mt = sum_or_na(catch_bet_mt),
    catch_bet_n = sum_or_na(catch_bet_n),
    catch_alb_mt = sum_or_na(catch_alb_mt),
    catch_alb_n = sum_or_na(catch_alb_n),
    catch_yft_mt = sum_or_na(catch_yft_mt),
    catch_yft_n = sum_or_na(catch_yft_n),
    .groups = "drop"
  ) |>

  filter(
    !if_all(c(catch_bet_mt, catch_alb_mt, catch_yft_mt,
              catch_bet_n, catch_alb_n, catch_yft_n), is.na),
    !if_all(c(catch_bet_mt, catch_alb_mt, catch_yft_mt,
              catch_bet_n, catch_alb_n, catch_yft_n), ~ .x == 0)
  ) |>

  arrange(year, lat, lon) |>

  select(
    rfmo, lon, lat, year,
    effort_t_hooks,
    catch_tot_mt, catch_tot_n,
    catch_bet_mt, catch_bet_n,
    catch_alb_mt, catch_alb_n,
    catch_yft_mt, catch_yft_n
  )

# EXPORT #######################################################################

saveRDS(ll_year, "data/processed/iotc/iotc_year_5deg_longline.rds")
