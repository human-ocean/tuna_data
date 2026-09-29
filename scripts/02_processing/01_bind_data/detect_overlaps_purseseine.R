################################################################################
# Check and export overlapping cells - Purse seine
################################################################################
#
# Emily Rodriguez
# ecr108@miami.edu
#
# This script defines overlapping cells between any two or more RFMOs at the monthly,
# yearly, and yearly flag level, visualizes them, and exports an RDS file of overlaps to be
# used in cleaning bound scripts.
#
################################################################################

# Load packages ----------------------------------------------------------------
library(tidyverse)
library(lubridate)
library(mapview)
library(sf)

# Load data --------------------------------------------------------------------
# Yearly data
yearly <- readRDS("data/processed/01_bound/allrfmo_year_1deg_purseseine.rds")

# Monthly data
monthly <- readRDS("data/processed/01_bound/allrfmo_month_1deg_purseseine.rds")

yearly_flag <- readRDS("data/processed/01_bound/allrfmo_year_1deg_purseseine_flag.rds")


# Find overlaps ----------------------------------------------------------------
# Detect yearly overlaps
yearly_overlap <- yearly |>
  group_by(lat, lon, year) |>
  filter(n_distinct(rfmo) >= 2) |>   # keep only cells reported by more than one RFMO
  ungroup()

# Summary table of overlapping cells per year
yearly_overlap_summary <- yearly_overlap |>
  group_by(year) |>
  summarise(n_cells = n_distinct(paste(lat, lon)), .groups = "drop")

# Detect monthly overlaps
monthly_overlap <- monthly |>
  group_by(lat, lon, year, month) |>
  filter(n_distinct(rfmo) >= 2) |>
  ungroup()

# Summary table of monthly overlaps
monthly_overlap_summary <- monthly_overlap |>
  group_by(year, month) |>
  summarise(n_cells = n_distinct(paste(lat, lon)), .groups = "drop")

# Detect overlaps in yearly flag data
yearly_flag_overlap <- yearly_flag |>
  group_by(lat, lon, year) |>
  filter(n_distinct(rfmo) >= 2) |>
  ungroup()

# Summary table of yearly flag overlaps
yearly_flag_overlap_summary <- yearly_flag_overlap |>
  group_by(year) |>
  summarise(
    n_cells = n_distinct(paste(lat, lon)),
    .groups = "drop"
  )

# Results ----------------------------------------------------------------------
# Yearly
yearly_overlap_summary

# Monthly
monthly_overlap_summary

# Yearly flag
yearly_flag_overlap_summary

# Determine if reporting is similar --------------------------------------------

# Aggregate yearly overlaps by RFMO
#yearly_ts <- yearly_overlap |>
#  group_by(year, rfmo) |>
#  summarise(
#    total_catch = sum(catch_tot, na.rm = TRUE),
#    total_effort = sum(effort_set, na.rm = TRUE),
#    .groups = "drop"
#  )

# Plot catch over years
#ggplot(yearly_ts, aes(x = year, y = total_catch, color = rfmo)) +
#  geom_line(size = 1.2) +
#  labs(
#    title = "Yearly Overlap",
#    x = "Year",
#    y = "Total Catch (tons)",
#    color = "RFMO"
#  ) +
#  theme_minimal()

# Plot effort over years
#ggplot(yearly_ts, aes(x = year, y = total_effort, color = rfmo)) +
#  geom_line(size = 1.2) +
#  labs(
#    title = "Yearly Overlap",
#    x = "Year",
#    y = "Total Effort (days or sets)",
#    color = "RFMO"
#  ) +
#  theme_minimal()

# Aggregate monthly overlaps by RFMO
#monthly_ts <- monthly_overlap |>
#  mutate(date = make_date(year, month, 1)) |>   # first day of the month
#  group_by(date, rfmo) |>
#  summarise(
#    total_catch = sum(catch_tot, na.rm = TRUE),
#    total_effort = sum(effort_set, na.rm = TRUE),
#    .groups = "drop"
#  )

# Plot monthly catch over time
#ggplot(monthly_ts, aes(x = date, y = total_catch, color = rfmo)) +
#  geom_line(size = 1.2) +
#  labs(
#    title = "Monthly Overlap",
#    x = "Date",
#    y = "Total Catch (tons)",
#    color = "RFMO"
#  ) +
#  theme_minimal()

# Plot monthly effort over time
#ggplot(monthly_ts, aes(x = date, y = total_effort, color = rfmo)) +
#  geom_line(size = 1.2) +
#  labs(
#    title = "Monthly Overlap",
#    x = "Date",
#    y = "Total Effort (days or sets)",
#    color = "RFMO"
#  ) +
#  theme_minimal()

# Visualize overlapping cells --------------------------------------------------

# Convert year data to sf
#yearly_sf <- yearly_overlap |>
#  distinct(lat, lon) |>
#  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# Map yearly
#mapview(yearly_sf,
#        legend = FALSE)

# Convert month data to sf
#monthly_sf <- monthly_overlap |>
#  distinct(lat, lon) |>
#  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# Map monthly
#mapview(monthly_sf,
#        legend = TRUE)

# See if IATTC is always highest ###############################################

# Compare catch and effort in yearly overlaps ----------------------------------

yearly_compare <- yearly_overlap |>
  group_by(lat, lon, year) |>
  summarise(
    catch_iattc  = sum(catch_tot[rfmo == "iattc"], na.rm = TRUE),
    catch_wcpfc  = sum(catch_tot[rfmo == "wcpfc"], na.rm = TRUE),
    effort_iattc = sum(effort_set[rfmo == "iattc"], na.rm = TRUE),
    effort_wcpfc = sum(effort_set[rfmo == "wcpfc"], na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    catch_winner = case_when(
      catch_iattc > catch_wcpfc ~ "iattc",
      catch_iattc < catch_wcpfc ~ "wcpfc",
      TRUE ~ "tie"
    ),
    effort_winner = case_when(
      effort_iattc > effort_wcpfc ~ "iattc",
      effort_iattc < effort_wcpfc ~ "wcpfc",
      TRUE ~ "tie"
    )
  )

# Compare catch and effort in monthly overlaps ---------------------------------

monthly_compare <- monthly_overlap |>
  group_by(lat, lon, year, month) |>
  summarise(
    catch_iattc  = sum(catch_tot[rfmo == "iattc"], na.rm = TRUE),
    catch_wcpfc  = sum(catch_tot[rfmo == "wcpfc"], na.rm = TRUE),
    effort_iattc = sum(effort_set[rfmo == "iattc"], na.rm = TRUE),
    effort_wcpfc = sum(effort_set[rfmo == "wcpfc"], na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    catch_winner = case_when(
      catch_iattc > catch_wcpfc ~ "iattc",
      catch_iattc < catch_wcpfc ~ "wcpfc",
      TRUE ~ "tie"
    ),
    effort_winner = case_when(
      effort_iattc > effort_wcpfc ~ "iattc",
      effort_iattc < effort_wcpfc ~ "wcpfc",
      TRUE ~ "tie"
    )
  )

# Summary
table(monthly_compare$catch_winner)
table(monthly_compare$effort_winner)
table(yearly_compare$catch_winner)
table(yearly_compare$effort_winner)

# Save and export overlap cells ------------------------------------------------

yearly_overlap_cells <- yearly_overlap |>
  distinct(lat, lon, year)

saveRDS(yearly_overlap_cells, "data/processed/01_bound/yearly_overlap_cells_purseseine.rds")

monthly_overlap_cells <- monthly_overlap |>
  distinct(lat, lon, year, month)

saveRDS(monthly_overlap_cells,"data/processed/01_bound/monthly_overlap_cells_purseseine.rds")

yearly_flag_overlap_cells <- yearly_flag_overlap |>
  distinct(lat, lon, year)

saveRDS(yearly_flag_overlap_cells,"data/processed/01_bound/yearly_flag_overlap_cells_purseseine.rds")
