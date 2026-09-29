################################################################################
# Bind longline monthly, 5x5 degree data
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This data binds longline tuna data from IATTC, ICCAT, and WCPFC at the
# monthly, 5x5 degree level with flag data.
#
################################################################################

# SET UP #######################################################################

# Load packages ----------------------------------------------------------------
library(tidyverse)

# Load data --------------------------------------------------------------------

iattc_clean <- readRDS("data/processed/iattc/iattc_month_5deg_longline_flag.rds")
iccat_clean <- readRDS("data/processed/iccat/iccat_month_5deg_longline_flag.rds")
wcpfc_clean <- readRDS("data/processed/wcpfc/wcpfc_month_5deg_longline_flag.rds")
iotc_clean  <- readRDS("data/processed/iotc/iotc_month_5deg_longline_flag.rds")

# PROCESSING ###################################################################

# Bind data sets ---------------------------------------------------------------

longline_all_month_flag <- bind_rows(
  iccat_clean,
  iattc_clean,
  wcpfc_clean,
  iotc_clean
) |>
  arrange(year, month, flag)

# EXPORT #######################################################################

saveRDS(longline_all_month_flag, "data/processed/01_bound/allrfmo_month_5deg_longline_flag.rds")
