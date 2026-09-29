################################################################################
# Prepare IOTC catch and effort data
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jxv893@miami.edu
#
# This R script processes the raw IOTC catch (CA) and effort (EF) files into two
# compact intermediate datasets, one for longline at 5x5 degrees and one for
# purse seine at 1x1 degrees, both monthly and by flag.
#
# IOTC reports catch and effort in two separate long-format files, each ~500 MB
# and ~115 MB. Digesting them once here avoids re-reading them in every cleaning
# script. See metadata in `data/raw/iotc` for an explanation of the fields.
#
# The two files are stratified differently and must be joined on different keys:
#
#   Longline  - school type is `UNCL` in both files and fishery/gear codes
#               correspond exactly, so the full stratum key is used.
#
#   Purse seine - effort is largely reported undifferentiated (`PSOT`/`UNCL`)
#               while catch is split by school type (`PSLS`/`LS`, `PSFS`/`FS`).
#               Joining on the full key would strand ~68% of catch rows with no
#               effort, so `FISHERY_CODE` and school type are dropped from the
#               key. This is lossless here because every purse seine product
#               aggregates over school type anyway.
#
################################################################################

# SET UP #######################################################################

## Load packages ---------------------------------------------------------------
library(tidyverse)
library(janitor)

## Build function to decode CWP grid codes -------------------------------------

### IOTC reports cells as CWP grid codes: [size][quadrant][lat 2][lon 3]
### size 5 → 1°x1° (offset 0.5); size 6 → 5°x5° (offset 2.5)
### quadrant 1 = NE, 2 = SE, 3 = SW, 4 = NW
### The offset is applied before the sign so that cells are centered away from
### the equator and Greenwich, not toward them.

parse_cwp_grid <- function(code) {
  code  <- as.character(code)
  size  <- str_sub(code, 1, 1)
  quad  <- str_sub(code, 2, 2)
  lat_d <- as.numeric(str_sub(code, 3, 4))
  lon_d <- as.numeric(str_sub(code, 5, 7))

  offset <- case_when(size == "5" ~ 0.5, size == "6" ~ 2.5)

  lat_sign <- case_when(quad %in% c("1", "4") ~ 1, quad %in% c("2", "3") ~ -1)
  lon_sign <- case_when(quad %in% c("1", "2") ~ 1, quad %in% c("3", "4") ~ -1)

  tibble(
    res = case_when(size == "5" ~ "1deg", size == "6" ~ "5deg"),
    lat = lat_sign * (lat_d + offset),
    lon = lon_sign * (lon_d + offset)
  )
}

## Build function to sum without turning all-NA groups into zero ---------------

### `sum(x, na.rm = TRUE)` returns 0 when every value is missing, which would
### report "not reported" as "zero effort". Large stretches of IOTC purse seine
### effort are not reported, so that distinction matters.

sum_or_na <- function(x) {
  if (all(is.na(x))) NA_real_ else sum(x, na.rm = TRUE)
}

## Build function to map IOTC fleet codes to ISO 3166-1 alpha-3 ----------------

### IOTC fleet codes are mostly ISO-3 already. The exceptions are EU member
### fleets (prefixed `EU`), the generic EU code, and `NEI` (not elsewhere
### included) codes, which do not identify a country.

recode_iotc_flag <- function(fleet) {
  case_when(
    # Generic EU and not-elsewhere-included fleets are not countries
    fleet == "EUREU" ~ NA_character_,
    str_starts(fleet, "NEI") ~ NA_character_,

    # EU member fleets keep the country after "EU"
    str_starts(fleet, "EU") ~ str_remove(fleet, "^EU"),

    # UK overseas territories fleet
    fleet == "GBRT" ~ "GBR",

    # Everything else is already ISO-3
    TRUE ~ fleet
  )
}

## Load data -------------------------------------------------------------------

raw_dir <- "data/raw/iotc/IOTC-DATASETS-2026-08-13-CE-1952-2025"

ca_raw <- read_csv(
  file.path(raw_dir, "IOTC-DATASETS-2026-08-13-CA-1952-2025.csv"),
  col_select = c(
    YEAR, MONTH_START, MONTH_END, FISHING_GROUND_CODE, FLEET_CODE,
    FISHERY_TYPE_CODE, FISHERY_GROUP_CODE, FISHERY_CODE, GEAR_CODE,
    CATCH_SCHOOL_TYPE_CODE, SPECIES_CODE, CATCH_UNIT_CODE, CATCH
  ),
  col_types = cols(
    YEAR = col_integer(),
    MONTH_START = col_integer(),
    MONTH_END = col_integer(),
    CATCH = col_double(),
    .default = col_character()
  )
) |>
  clean_names()

ef_raw <- read_csv(
  file.path(raw_dir, "IOTC-DATASETS-2026-08-13-EF-1952-2025.csv"),
  col_select = c(
    YEAR, MONTH_START, MONTH_END, FISHING_GROUND_CODE, FLEET_CODE,
    FISHERY_TYPE_CODE, FISHERY_GROUP_CODE, FISHERY_CODE, GEAR_CODE,
    SCHOOL_TYPE_CODE, EFFORT_UNIT_CODE, EFFORT
  ),
  col_types = cols(
    YEAR = col_integer(),
    MONTH_START = col_integer(),
    MONTH_END = col_integer(),
    EFFORT = col_double(),
    .default = col_character()
  )
) |>
  clean_names()

# PROCESSING ###################################################################

## Define the species and join keys used throughout ----------------------------

species_keep <- c("SKJ", "ALB", "BET", "YFT")

# Longline: school type is always UNCL and fishery/gear codes match between
# files, so the full stratum key can be used
ll_keys <- c(
  "year", "month", "fishing_ground_code", "fleet_code",
  "fishery_type_code", "fishery_code", "gear_code", "school_type_code",
  "lat", "lon", "flag"
)

# Purse seine: fishery code and school type are stratified differently between
# the two files and are dropped from the key
ps_keys <- c(
  "year", "month", "fishing_ground_code", "fleet_code",
  "fishery_type_code", "gear_code",
  "lat", "lon", "flag"
)

## Filter and decode both files ------------------------------------------------

prep_common <- function(x, school_col) {
  out <- x |>
    # Drop strata that span more than one month (mostly longline annual rollups)
    filter(month_start == month_end) |>
    rename(month = month_start, school_type_code = all_of(school_col)) |>

    # Keep only the gear and grid combinations used downstream
    filter(
      (fishery_group_code == "PS" & str_starts(fishing_ground_code, "5")) |
        (fishery_group_code == "LL" & str_starts(fishing_ground_code, "6"))
    )

  # Decode cells and flags
  centered <- parse_cwp_grid(out$fishing_ground_code)

  out |>
    mutate(
      res = centered$res,
      lat = centered$lat,
      lon = centered$lon,
      flag = recode_iotc_flag(fleet_code)
    )
}

ca <- prep_common(ca_raw, "catch_school_type_code") |>
  filter(species_code %in% species_keep)

ef <- prep_common(ef_raw, "school_type_code")

## Build longline intermediate -------------------------------------------------

ll_catch <- ca |>
  filter(fishery_group_code == "LL") |>
  group_by(across(all_of(ll_keys)), species_code, catch_unit_code) |>
  summarise(catch = sum(catch, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(
    names_from = c(species_code, catch_unit_code),
    values_from = catch
  ) |>
  clean_names()

ll_effort <- ef |>
  filter(fishery_group_code == "LL") |>
  group_by(across(all_of(ll_keys)), effort_unit_code) |>
  summarise(effort = sum(effort, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(names_from = effort_unit_code, values_from = effort) |>
  clean_names() |>
  select(all_of(ll_keys), hooks)

ll_joined <- ll_catch |>
  left_join(ll_effort, by = ll_keys)

iotc_longline <- ll_joined |>
  # Collapse strata to the cell level, keeping flag
  group_by(year, month, lat, lon, flag) |>
  summarise(across(where(is.numeric), sum_or_na), .groups = "drop")

## Build purse seine intermediate ----------------------------------------------

ps_catch <- ca |>
  filter(fishery_group_code == "PS") |>
  group_by(across(all_of(ps_keys)), species_code, catch_unit_code) |>
  summarise(catch = sum(catch, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(
    names_from = c(species_code, catch_unit_code),
    values_from = catch
  ) |>
  clean_names()

ps_effort_all <- ef |>
  filter(fishery_group_code == "PS") |>
  group_by(across(all_of(ps_keys)), effort_unit_code) |>
  summarise(effort = sum(effort, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(names_from = effort_unit_code, values_from = effort) |>
  clean_names()

# Only effort units matching the rest of the project are retained. Hours,
# standardized hours, trips and days at sea are not comparable to sets or
# fishing days and are dropped.
ps_effort <- ps_effort_all |>
  select(all_of(ps_keys), sets, fdays)

ps_joined <- ps_catch |>
  left_join(ps_effort, by = ps_keys)

iotc_purseseine <- ps_joined |>
  # Collapse strata to the cell level, keeping flag
  group_by(year, month, lat, lon, flag) |>
  summarise(across(where(is.numeric), sum_or_na), .groups = "drop")

## Checks ######################################################################

# 1. Rows dropped by each filter -----------------------------------------------
cat("CA rows raw:            ", nrow(ca_raw), "\n")
cat("CA rows after filters:  ", nrow(ca), "\n")
cat("EF rows raw:            ", nrow(ef_raw), "\n")
cat("EF rows after filters:  ", nrow(ef), "\n")

# 2. pivot_wider did not create list-columns -----------------------------------
# TRUE = the stratum/species/unit combinations were unique
!any(map_lgl(ll_catch, is.list))
!any(map_lgl(ps_catch, is.list))

# 3. Share of catch strata matched to effort -----------------------------------
# Expect ~97% of longline strata to carry hooks. The purse seine figure is the
# share carrying sets or fishing days, which is low by design: hours, trips and
# days at sea are not retained. What matters is that the join itself matched, so
# the share of strata matched to ANY effort record is reported separately below.
cat("LL strata with hooks:   ", mean(!is.na(ll_joined$hooks)), "\n")
cat("PS strata with sets:    ", mean(!is.na(ps_joined$sets)), "\n")
cat("PS strata with fdays:   ", mean(!is.na(ps_joined$fdays)), "\n")
cat("PS strata with either:  ",
    mean(!is.na(ps_joined$sets) | !is.na(ps_joined$fdays)), "\n")

# Share of purse seine catch strata that matched an effort record at all,
# regardless of unit. Expect ~100%; anything lower means the key is too strict.
cat("PS strata matched (any unit): ",
    nrow(semi_join(ps_catch, ps_effort_all, by = ps_keys)) / nrow(ps_catch), "\n")

# 4. Cells are centered on the expected grid -----------------------------------
# TRUE = the CWP decode placed cells on 5° and 1° centers
all(iotc_longline$lat %% 5 == 2.5) && all(iotc_longline$lon %% 5 == 2.5)
all(iotc_purseseine$lat %% 1 == 0.5) && all(iotc_purseseine$lon %% 1 == 0.5)

# EXPORT #######################################################################

saveRDS(
  iotc_longline,
  file.path(raw_dir, "iotc_month_5deg_longline_prepped.rds")
)

saveRDS(
  iotc_purseseine,
  file.path(raw_dir, "iotc_month_1deg_purseseine_prepped.rds")
)
