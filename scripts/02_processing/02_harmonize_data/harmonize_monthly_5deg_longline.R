################################################################################
# Harmonize purse seine monthly, 1x1 degree data
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This script harmonizes longline data from the bound dataset (IATTC,
# ICCAT, IOTC, and WCPFC) to resolve overlapping cells between any two or more
# RFMOs. The RFMO with higher catch and effort reported was kept. If the
# reporting was the same, the record is kept following the priority order
# WCPFC > IATTC > IOTC > ICCAT.
#
# The output is the final monthly harmonized monthly, 5x5 degree dataset.
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

monthly_bound <- readRDS("data/processed/01_bound/allrfmo_month_5deg_longline.rds")
monthly_overlap_cells <- readRDS("data/processed/01_bound/monthly_overlap_cells_longline.rds")

# Load spatial data ------------------------------------------------------------

countries <- ne_countries(
  scale = "medium",
  returnclass = "sf"
)

# PROCESSING ###################################################################

# Check if metric tons are always higher than number reporting in overlapping
# cells ------------------------------------------------------------------------

# Filter to overlapping cells only
#ll_overlap <- monthly_bound |>
#  inner_join(monthly_overlap_cells,
             #by = c("lat","lon","year","month"))

# Collapse duplicates within RFMO and cell
#ll_collapse <- ll_overlap |>
#  group_by(lat, lon, year, month, rfmo) |>
#  summarise(
#    mt = sum(catch_tot_mt, na.rm = TRUE),
#    n  = sum(catch_tot_n,  na.rm = TRUE),
#    .groups = "drop"
#  )

# Pivot wider to compare IATTC vs WCPFC directly
#ll_wide <- ll_collapse |>
#  pivot_wider(
#    names_from = rfmo,
#    values_from = c(mt, n)
#  )

# Compare whether MT and N agree on which RFMO is higher
#ll_compare <- ll_wide |>
#  mutate(
#    mt_agrees = case_when(
#      mt_iattc > mt_wcpfc & n_iattc > n_wcpfc ~ TRUE,
#      mt_iattc < mt_wcpfc & n_iattc < n_wcpfc ~ TRUE,
#      TRUE ~ FALSE
#    )
#  )

# Summarize agreement
#ll_compare |>
#  summarise(
#    n_cells = n(),
#    pct_agree = mean(mt_agrees, na.rm = TRUE)
#  )

# About 83% of reportings match (if mt greater, num also greater)
# Some reportings where match did not occur had almost the same reporting,
# close by decimals

# Harmonize --------------------------------------------------------------------
monthly <- monthly_bound |>

  # Mark overlapping cells
  left_join(
    monthly_overlap_cells |> mutate(overlap = TRUE),
    by = c("lat", "lon", "year", "month")
  ) |>

  group_by(lat, lon, year, month) |>

  # Avoid NA warnings
  mutate(
    max_mt  = if (all(is.na(catch_tot_mt)))  NA_real_ else max(catch_tot_mt,  na.rm = TRUE),
    max_n = if (all(is.na(catch_tot_n))) NA_real_ else max(catch_tot_n, na.rm = TRUE)
  ) |>

  # Keep:
  #   - all non-overlap rows
  #   - rows with highest MT
  #   - if MT ties, rows with highest N
  filter(
    is.na(overlap) |
      (!is.na(max_mt)  & catch_tot_mt  == max_mt) |
      ( is.na(max_mt)  & !is.na(max_n) & catch_tot_n == max_n)
  ) |>

  # If still tied, keep the highest priority RFMO
  slice_min(match(rfmo, rfmo_priority), n = 1, with_ties = FALSE) |>

  ungroup() |>
  select(-overlap, -max_mt, -max_n)

# Remove points that fall on land ----------------------------------------------

monthly_final <- monthly |>
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

saveRDS(monthly_final, "data/output/allrfmo_month_5deg_longline.rds")

