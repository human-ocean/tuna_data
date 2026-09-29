################################################################################
# Check and export overlapping cells - Longline
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This script defines overlapping cells between any two or more RFMOs for longline
# at the monthly, yearly, monthly flag, and yearly flag level, and exports
# overlap-cell RDS files to be used in cleaning bound scripts.
#
################################################################################

# Load packages ----------------------------------------------------------------
library(tidyverse)
library(lubridate)
library(mapview)
library(sf)

# Load data --------------------------------------------------------------------
# Yearly data (no flag)
yearly_ll <- readRDS("data/processed/01_bound/allrfmo_year_5deg_longline.rds")

# Monthly data (no flag)
monthly_ll <- readRDS("data/processed/01_bound/allrfmo_month_5deg_longline.rds")

# Yearly flag data
yearly_flag_ll <- readRDS("data/processed/01_bound/allrfmo_year_5deg_longline_flag.rds")

# Monthly flag data
monthly_flag_ll <- readRDS("data/processed/01_bound/allrfmo_month_5deg_longline_flag.rds")

# Find overlaps ----------------------------------------------------------------
# Detect yearly overlaps (no flag)
yearly_ll_overlap <- yearly_ll |>
  group_by(lat, lon, year) |>
  filter(n_distinct(rfmo) >= 2) |>
  ungroup()

yearly_ll_overlap_summary <- yearly_ll_overlap |>
  group_by(year) |>
  summarise(
    n_cells = n_distinct(paste(lat, lon)),
    .groups = "drop"
  )

# Detect monthly overlaps (no flag)
monthly_ll_overlap <- monthly_ll |>
  group_by(lat, lon, year, month) |>
  filter(n_distinct(rfmo) >= 2) |>
  ungroup()

monthly_ll_overlap_summary <- monthly_ll_overlap |>
  group_by(year, month) |>
  summarise(
    n_cells = n_distinct(paste(lat, lon)),
    .groups = "drop"
  )

# Detect overlaps in yearly flag data
yearly_flag_ll_overlap <- yearly_flag_ll |>
  group_by(lat, lon, year) |>
  filter(n_distinct(rfmo) >= 2) |>
  ungroup()

yearly_flag_ll_overlap_summary <- yearly_flag_ll_overlap |>
  group_by(year) |>
  summarise(
    n_cells = n_distinct(paste(lat, lon)),
    .groups = "drop"
  )

# Detect overlaps in monthly flag data
monthly_flag_ll_overlap <- monthly_flag_ll |>
  group_by(lat, lon, year, month) |>
  filter(n_distinct(rfmo) >= 2) |>
  ungroup()

monthly_flag_ll_overlap_summary <- monthly_flag_ll_overlap |>
  group_by(year, month) |>
  summarise(
    n_cells = n_distinct(paste(lat, lon)),
    .groups = "drop"
  )

# Results ----------------------------------------------------------------------
yearly_ll_overlap_summary
monthly_ll_overlap_summary
yearly_flag_ll_overlap_summary
monthly_flag_ll_overlap_summary

# Save and export overlap cells ------------------------------------------------
yearly_ll_overlap_cells <- yearly_ll_overlap |>
  distinct(lat, lon, year)

saveRDS(
  yearly_ll_overlap_cells,
  "data/processed/01_bound/yearly_overlap_cells_longline.rds"
)

monthly_ll_overlap_cells <- monthly_ll_overlap |>
  distinct(lat, lon, year, month)

saveRDS(
  monthly_ll_overlap_cells,
  "data/processed/01_bound/monthly_overlap_cells_longline.rds"
)

yearly_flag_ll_overlap_cells <- yearly_flag_ll_overlap |>
  distinct(lat, lon, year)

saveRDS(
  yearly_flag_ll_overlap_cells,
  "data/processed/01_bound/yearly_flag_overlap_cells_longline.rds"
)

monthly_flag_ll_overlap_cells <- monthly_flag_ll_overlap |>
  distinct(lat, lon, year, month)

saveRDS(
  monthly_flag_ll_overlap_cells,
  "data/processed/01_bound/monthly_flag_overlap_cells_longline.rds"
)
