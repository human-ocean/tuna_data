################################################################################
# Bind purse seine monthly, 1x1 degree data
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This data binds purse seine tuna data from IATTC, ICCAT, and WCPFC at the
# yearly, 1x1 degree level.
#
################################################################################

# SET UP #######################################################################

# Load packages ----------------------------------------------------------------
library(tidyverse)

# Load data --------------------------------------------------------------------

iattc_clean <- readRDS("data/processed/iattc/iattc_month_1deg_purseseine.rds")
iccat_clean <- readRDS("data/processed/iccat/iccat_month_1deg_purseseine.rds")
wcpfc_clean <- readRDS("data/processed/wcpfc/wcpfc_month_1deg_purseseine.rds")
iotc_clean  <- readRDS("data/processed/iotc/iotc_month_1deg_purseseine.rds")

# PROCESSING ###################################################################

# Bind data sets ---------------------------------------------------------------

tuna_all_clean <- bind_rows(
  iccat_clean,
  iattc_clean,
  wcpfc_clean,
  iotc_clean) |>
    arrange(year, month)

# EXPORT #######################################################################
saveRDS(tuna_all_clean, "data/processed/01_bound/allrfmo_month_1deg_purseseine.rds")

