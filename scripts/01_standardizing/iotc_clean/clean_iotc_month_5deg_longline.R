################################################################################
# Clean IOTC longline data
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jxv893@miami.edu
#
# This R script processes prepared longline tuna catch and effort data from the
# IOTC at the month, 5 degree level, aggregated across flags.
#
# IOTC reports skipjack in its longline data, but the other RFMOs do not, so
# `catch_skj` is dropped here to keep the longline datasets comparable.
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

longline_prepped <- readRDS(
  "data/raw/iotc/IOTC-DATASETS-2026-08-13-CE-1952-2025/iotc_month_5deg_longline_prepped.rds"
)

# PROCESSING ###################################################################

iotc_month_5deg_longline_clean <- longline_prepped |>

  # Aggregate across flags
  group_by(lon, lat, year, month) |>
  summarise(
    hooks = sum_or_na(hooks),
    bet_mt = sum_or_na(bet_mt),
    alb_mt = sum_or_na(alb_mt),
    yft_mt = sum_or_na(yft_mt),
    bet_no = sum_or_na(bet_no),
    alb_no = sum_or_na(alb_no),
    yft_no = sum_or_na(yft_no),
    .groups = "drop"
  ) |>

  mutate(
    # Effort to thousands of hooks
    effort_t_hooks = hooks / 1000,

    # Species specific catch in mt
    catch_bet_mt = bet_mt,
    catch_alb_mt = alb_mt,
    catch_yft_mt = yft_mt,

    # Species specific catch in numbers
    catch_bet_n = bet_no,
    catch_alb_n = alb_no,
    catch_yft_n = yft_no,

    # Total catch (metric tons + numbers)
    catch_tot_mt = rowSums(across(c(catch_bet_mt, catch_alb_mt, catch_yft_mt)), na.rm = TRUE),
    catch_tot_n = rowSums(across(c(catch_bet_n, catch_alb_n, catch_yft_n)), na.rm = TRUE),

    rfmo = "iotc"
  ) |>

  # Remove rows where all three species are NA or all zero
  filter(
    !if_all(c(catch_bet_mt, catch_alb_mt, catch_yft_mt,
              catch_bet_n, catch_alb_n, catch_yft_n), is.na),
    !if_all(c(catch_bet_mt, catch_alb_mt, catch_yft_mt,
              catch_bet_n, catch_alb_n, catch_yft_n), ~ .x == 0)
  ) |>

  arrange(year, month) |>

  select(
    rfmo, lon, lat, year, month,
    effort_t_hooks,
    catch_tot_mt, catch_tot_n,
    catch_bet_mt, catch_bet_n,
    catch_alb_mt, catch_alb_n,
    catch_yft_mt, catch_yft_n
  )

# EXPORT #######################################################################

saveRDS(
  iotc_month_5deg_longline_clean,
  "data/processed/iotc/iotc_month_5deg_longline.rds"
)
