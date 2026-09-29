################################################################################
# Bind longline yearly, 5x5 degree data
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This data binds longline tuna data from IATTC, ICCAT, and WCPFC at the
# monthly, 5x5 degree level (no flag).
#
################################################################################

# SET UP #######################################################################

# Load packages ----------------------------------------------------------------
library(tidyverse)

# Load data --------------------------------------------------------------------

iattc_clean <- readRDS("data/processed/iattc/iattc_year_5deg_longline.rds")
iccat_clean <- readRDS("data/processed/iccat/iccat_year_5deg_longline.rds")
wcpfc_clean <- readRDS("data/processed/wcpfc/wcpfc_year_5deg_longline_flag.rds") |>
  select(-flag)
iotc_clean  <- readRDS("data/processed/iotc/iotc_year_5deg_longline.rds")

# PROCESSING ###################################################################

# Bind data sets ---------------------------------------------------------------

longline_all_year <- bind_rows(
  iccat_clean,
  iattc_clean,
  wcpfc_clean,
  iotc_clean
) |>
  arrange(year)

# EXPORT #######################################################################

saveRDS(longline_all_year, "data/processed/01_bound/allrfmo_year_5deg_longline.rds")
