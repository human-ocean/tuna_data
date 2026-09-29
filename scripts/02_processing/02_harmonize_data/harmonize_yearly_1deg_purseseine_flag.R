################################################################################
# Harmonize purse seine yearly, 1x1 degree flag data
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This script harmonizes purse seine tuna data from the bound dataset (IATTC,
# ICCAT, IOTC, and WCPFC) to resolve overlapping cells between any two or more
# RFMOs. The RFMO with higher catch and effort reported was kept. If the
# reporting was the same, the record is kept following the priority order
# WCPFC > IATTC > IOTC > ICCAT.
#
# The output is the final monthly harmonized monthly, 1x1 degree dataset.
#
#
################################################################################

# SET UP #######################################################################

# Load packages ----------------------------------------------------------------
library(tidyverse)
library(sf)
library(rnaturalearth)

# RFMO priority for breaking ties in overlapping cells ------------------------
# Used only when catch and effort cannot distinguish the overlapping records.
rfmo_priority <- c("wcpfc", "iattc", "iotc", "iccat")

# Load data --------------------------------------------------------------------

yearly_flag_bound <- readRDS("data/processed/01_bound/allrfmo_year_1deg_purseseine_flag.rds")
yearly_overlap_cells <- readRDS("data/processed/01_bound/yearly_flag_overlap_cells_purseseine.rds")

# Load spatial data ------------------------------------------------------------

countries <- ne_countries(
  scale = "medium",
  returnclass = "sf"
)

# PROCESSING ###################################################################

# Harmonize --------------------------------------------------------------------
yearly_flag <- yearly_flag_bound |>

  # Mark overlapping cells
  left_join(yearly_overlap_cells |> mutate(overlap = TRUE),
            by = c("lat", "lon", "year")) |>

  group_by(lat, lon, year, flag) |>

  # Avoid NA warnings
  mutate(
    max_catch  = if (all(is.na(catch_tot)))  NA_real_ else max(catch_tot,  na.rm = TRUE),
    max_effort = if (all(is.na(effort_set))) NA_real_ else max(effort_set, na.rm = TRUE)
  ) |>

  # Keep:
  #   - all non-overlap rows
  #   - rows with highest catch
  #   - if catch ties, rows with highest effort
  filter(
    is.na(overlap) |
      (!is.na(max_catch)  & catch_tot  == max_catch) |
      ( is.na(max_catch)  & !is.na(max_effort) & effort_set == max_effort)
  ) |>

  # If still tied, keep the highest priority RFMO
  slice_min(match(rfmo, rfmo_priority), n = 1, with_ties = FALSE) |>

  ungroup() |>
  select(-overlap, -max_catch, -max_effort)

# Remove points that fall on land ----------------------------------------------

yearly_flag_final <- yearly_flag |>
  st_as_sf(
    coords = c("lon", "lat"),
    crs = 4326,
    remove = FALSE
  ) |>
  filter(
    lengths(st_within(geometry, countries)) == 0
  ) |>
  st_drop_geometry()

# EXPORT #######################################################################
saveRDS(yearly_flag_final, "data/output/allrfmo_year_1deg_purseseine_flag.rds")

