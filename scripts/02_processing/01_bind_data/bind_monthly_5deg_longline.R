################################################################################
# Bind longline monthly, 5x5 degree data
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

iattc_clean <- readRDS("data/processed/iattc/iattc_month_5deg_longline.rds")
iccat_clean <- readRDS("data/processed/iccat/iccat_month_5deg_longline.rds")
wcpfc_clean <- readRDS("data/processed/wcpfc/wcpfc_month_5deg_longline.rds")
iotc_clean  <- readRDS("data/processed/iotc/iotc_month_5deg_longline.rds")

# PROCESSING ###################################################################

# Bind data sets ---------------------------------------------------------------

longline_all_month <- bind_rows(
  iccat_clean,
  iattc_clean,
  wcpfc_clean,
  iotc_clean
) |>
  arrange(year, month)

# EXPORT #######################################################################

saveRDS(longline_all_month, "data/processed/01_bound/allrfmo_month_5deg_longline.rds")
