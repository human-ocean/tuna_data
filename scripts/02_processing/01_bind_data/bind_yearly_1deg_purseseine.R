################################################################################
# Bind purse seine yearly, 1x1 degree data
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This data binds  purse seine tuna data from IATTC, ICCAT, and WCPFC at the
# monthly, 1x1 degree level.
#
################################################################################

# SET UP #######################################################################

library(tidyverse)

# Load Data --------------------------------------------------------------------

iattc_year  <- readRDS("data/processed/iattc/iattc_year_1deg_purseseine.rds")
iccat_year  <- readRDS("data/processed/iccat/iccat_year_1deg_purseseine.rds")
wcpfc_year  <- readRDS("data/processed/wcpfc/wcpfc_year_1deg_purseseine.rds")
iotc_year   <- readRDS("data/processed/iotc/iotc_year_1deg_purseseine.rds")

# PROCESSING ###################################################################

# Bind datasets
tuna_all_year <- bind_rows(
  iccat_year,
  iattc_year,
  wcpfc_year,
  iotc_year
) |>
  arrange(year)

# EXPORT #######################################################################

saveRDS(tuna_all_year, "data/processed/01_bound/allrfmo_year_1deg_purseseine.rds")

