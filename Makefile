###############################
# Directories
###############################

# General data and scripts
OUT = data/output/
DATA_BIND = data/processed/01_bound/

PROC_BIND = scripts/02_processing/01_bind_data/
PROC_HARM = scripts/02_processing/02_harmonize_data/

# RFMO specific
## IATTC
RAW_IATTC = data/raw/iattc/
ST_IATTC = scripts/01_standardizing/iattc_clean/
PROC_IATTC = data/processed/iattc/

## ICCAT
RAW_ICCAT  = data/raw/iccat/
ST_ICCAT   = scripts/01_standardizing/iccat_clean/
PROC_ICCAT = data/processed/iccat/

## IOTC
RAW_IOTC    = data/raw/iotc/
RAW_IOTC_CE = data/raw/iotc/IOTC-DATASETS-2026-08-13-CE-1952-2025/
ST_IOTC     = scripts/01_standardizing/iotc_clean/
PROC_IOTC   = data/processed/iotc/

## WCPFC
RAW_WCPFC  = data/raw/wcpfc/
ST_WCPFC   = scripts/01_standardizing/wcpfc_clean/
PROC_WCPFC = data/processed/wcpfc/

###############################
# Define functions
###############################

all: \
	$(OUT)allrfmo_month_1deg_purseseine.rds \
	$(OUT)allrfmo_year_1deg_purseseine.rds \
	$(OUT)allrfmo_year_1deg_purseseine_flag.rds \
	$(OUT)allrfmo_month_5deg_longline.rds \
	$(OUT)allrfmo_month_5deg_longline_flag.rds \
	$(OUT)allrfmo_year_5deg_longline.rds \
	$(OUT)allrfmo_year_5deg_longline_flag.rds \
	$(OUT)allrfmo_month_1deg_purseseine.csv \
	$(OUT)allrfmo_year_1deg_purseseine.csv \
	$(OUT)allrfmo_year_1deg_purseseine_flag.csv \
	$(OUT)allrfmo_month_5deg_longline.csv \
	$(OUT)allrfmo_month_5deg_longline_flag.csv \
	$(OUT)allrfmo_year_5deg_longline.csv \
	$(OUT)allrfmo_year_5deg_longline_flag.csv \
	$(OUT)wcpfc_length_data.rds

iattc: \
	$(PROC_IATTC)iattc_month_1deg_purseseine.rds \
	$(PROC_IATTC)iattc_year_1deg_purseseine.rds \
	$(PROC_IATTC)iattc_year_1deg_purseseine_flag.rds \
	$(PROC_IATTC)iattc_month_5deg_longline.rds \
	$(PROC_IATTC)iattc_month_5deg_longline_flag.rds \
	$(PROC_IATTC)iattc_year_5deg_longline.rds \
	$(PROC_IATTC)iattc_year_5deg_longline_flag.rds

iccat: \
	$(PROC_ICCAT)iccat_month_1deg_purseseine.rds \
	$(PROC_ICCAT)iccat_year_1deg_purseseine.rds \
	$(PROC_ICCAT)iccat_year_1deg_purseseine_flag.rds \
	$(PROC_ICCAT)iccat_month_5deg_longline.rds \
	$(PROC_ICCAT)iccat_month_5deg_longline_flag.rds \
	$(PROC_ICCAT)iccat_year_5deg_longline.rds \
	$(PROC_ICCAT)iccat_year_5deg_longline_flag.rds

iotc: \
	$(PROC_IOTC)iotc_month_1deg_purseseine.rds \
	$(PROC_IOTC)iotc_year_1deg_purseseine.rds \
	$(PROC_IOTC)iotc_year_1deg_purseseine_flag.rds \
	$(PROC_IOTC)iotc_month_5deg_longline.rds \
	$(PROC_IOTC)iotc_month_5deg_longline_flag.rds \
	$(PROC_IOTC)iotc_year_5deg_longline.rds \
	$(PROC_IOTC)iotc_year_5deg_longline_flag.rds

wcpfc: \
	$(PROC_WCPFC)wcpfc_month_1deg_purseseine.rds \
	$(PROC_WCPFC)wcpfc_year_1deg_purseseine.rds \
	$(PROC_WCPFC)wcpfc_year_1deg_purseseine_flag.rds \
	$(PROC_WCPFC)wcpfc_month_5deg_longline.rds \
	$(PROC_WCPFC)wcpfc_month_5deg_longline_flag.rds \
	$(PROC_WCPFC)wcpfc_year_5deg_longline_flag.rds \
	$(OUT)wcpfc_length_data.rds

###############################
# IATTC data preparation
###############################

$(RAW_IATTC)month_5deg_longline_flag/month_5deg_longline_flag_merged.rds: \
	$(ST_IATTC)merge_longline_data.R \
	$(RAW_IATTC)month_5deg_longline_flag/month_5deg_longline_flag_mt.csv \
	$(RAW_IATTC)month_5deg_longline_flag/month_5deg_longline_flag_num.csv
	Rscript $<

###############################
# IATTC, purse seine
###############################

# Month
$(PROC_IATTC)iattc_month_1deg_purseseine.rds: \
	$(ST_IATTC)clean_iattc_month_1deg_purseseine.R \
	$(RAW_IATTC)month_1deg_purseseine/month_1deg_purseseine_flag.csv
	Rscript $<

# Year
$(PROC_IATTC)iattc_year_1deg_purseseine.rds: \
	$(ST_IATTC)aggregate_monthly_to_year_iattc_1deg_purseseine.R \
	$(PROC_IATTC)iattc_month_1deg_purseseine.rds
	Rscript $<

# Year, flag
$(PROC_IATTC)iattc_year_1deg_purseseine_flag.rds: \
	$(ST_IATTC)aggregate_monthly_to_year_iattc_1deg_purseseine_flag.R \
	$(RAW_IATTC)month_1deg_purseseine/month_1deg_purseseine_flag.csv
	Rscript $<

###############################
# IATTC, longline
###############################

# Month
$(PROC_IATTC)iattc_month_5deg_longline.rds: \
	$(ST_IATTC)clean_iattc_month_5deg_longline.R \
	$(RAW_IATTC)month_5deg_longline_flag/month_5deg_longline_flag_merged.rds
	Rscript $<

# Month, flag
$(PROC_IATTC)iattc_month_5deg_longline_flag.rds: \
	$(ST_IATTC)clean_iattc_month_5deg_longline_flag.R \
	$(RAW_IATTC)month_5deg_longline_flag/month_5deg_longline_flag_merged.rds
	Rscript $<

# Year
$(PROC_IATTC)iattc_year_5deg_longline.rds: \
	$(ST_IATTC)aggregate_monthly_to_year_iattc_5deg_longline.R \
	$(RAW_IATTC)month_5deg_longline_flag/month_5deg_longline_flag_merged.rds
	Rscript $<

# Year, flag
$(PROC_IATTC)iattc_year_5deg_longline_flag.rds: \
	$(ST_IATTC)aggregate_monthly_to_year_iattc_5deg_longline_flag.R \
	$(RAW_IATTC)month_5deg_longline_flag/month_5deg_longline_flag_merged.rds
	Rscript $<

###############################
# ICCAT data preparation
###############################

$(RAW_ICCAT)ms_database_all/iccat_database.rds: \
	$(ST_ICCAT)convert_iccat_mdb_to_rds.R \
	$(RAW_ICCAT)ms_database_all/ms_database_all.mdb
	Rscript $<

###############################
# ICCAT, purse seine
###############################

# Month
$(PROC_ICCAT)iccat_month_1deg_purseseine.rds: \
	$(ST_ICCAT)clean_iccat_month_1deg_purseseine.R \
	$(RAW_ICCAT)ms_database_all/iccat_database.rds
	Rscript $<

# Year
$(PROC_ICCAT)iccat_year_1deg_purseseine.rds: \
	$(ST_ICCAT)clean_iccat_year_1deg_purseseine.R \
	$(RAW_ICCAT)ms_database_all/iccat_database.rds
	Rscript $<

# Year, flag
$(PROC_ICCAT)iccat_year_1deg_purseseine_flag.rds: \
	$(ST_ICCAT)clean_iccat_year_1deg_purseseine_flag.R \
	$(RAW_ICCAT)ms_database_all/iccat_database.rds
	Rscript $<

###############################
# ICCAT, longline
###############################

# Month
$(PROC_ICCAT)iccat_month_5deg_longline.rds: \
	$(ST_ICCAT)clean_iccat_month_5deg_longline.R \
	$(RAW_ICCAT)ms_database_all/iccat_database.rds
	Rscript $<

# Month, flag
$(PROC_ICCAT)iccat_month_5deg_longline_flag.rds: \
	$(ST_ICCAT)clean_iccat_month_5deg_longline_flag.R \
	$(RAW_ICCAT)ms_database_all/iccat_database.rds
	Rscript $<

# Year
$(PROC_ICCAT)iccat_year_5deg_longline.rds: \
	$(ST_ICCAT)clean_iccat_year_5deg_longline.R \
	$(RAW_ICCAT)ms_database_all/iccat_database.rds
	Rscript $<

# Year, flag
$(PROC_ICCAT)iccat_year_5deg_longline_flag.rds: \
	$(ST_ICCAT)clean_iccat_year_5deg_longline_flag.R \
	$(RAW_ICCAT)ms_database_all/iccat_database.rds
	Rscript $<

###############################
# IOTC data preparation
###############################

# The preparation script reads the raw catch and effort files once and writes
# both intermediates in a single pass.
$(RAW_IOTC_CE)iotc_month_5deg_longline_prepped.rds \
$(RAW_IOTC_CE)iotc_month_1deg_purseseine_prepped.rds: \
	$(ST_IOTC)prep_iotc_catch_effort.R \
	$(RAW_IOTC_CE)IOTC-DATASETS-2026-08-13-CA-1952-2025.csv \
	$(RAW_IOTC_CE)IOTC-DATASETS-2026-08-13-EF-1952-2025.csv
	Rscript $<

###############################
# IOTC, purse seine
###############################

# Month
$(PROC_IOTC)iotc_month_1deg_purseseine.rds: \
	$(ST_IOTC)clean_iotc_month_1deg_purseseine.R \
	$(RAW_IOTC_CE)iotc_month_1deg_purseseine_prepped.rds
	Rscript $<

# Year
$(PROC_IOTC)iotc_year_1deg_purseseine.rds: \
	$(ST_IOTC)aggregate_monthly_to_year_iotc_1deg_purseseine.R \
	$(PROC_IOTC)iotc_month_1deg_purseseine.rds
	Rscript $<

# Year, flag
$(PROC_IOTC)iotc_year_1deg_purseseine_flag.rds: \
	$(ST_IOTC)aggregate_monthly_to_year_iotc_1deg_purseseine_flag.R \
	$(RAW_IOTC_CE)iotc_month_1deg_purseseine_prepped.rds
	Rscript $<

###############################
# IOTC, longline
###############################

# Month
$(PROC_IOTC)iotc_month_5deg_longline.rds: \
	$(ST_IOTC)clean_iotc_month_5deg_longline.R \
	$(RAW_IOTC_CE)iotc_month_5deg_longline_prepped.rds
	Rscript $<

# Month, flag
$(PROC_IOTC)iotc_month_5deg_longline_flag.rds: \
	$(ST_IOTC)clean_iotc_month_5deg_longline_flag.R \
	$(RAW_IOTC_CE)iotc_month_5deg_longline_prepped.rds
	Rscript $<

# Year
$(PROC_IOTC)iotc_year_5deg_longline.rds: \
	$(ST_IOTC)aggregate_monthly_to_year_iotc_5deg_longline.R \
	$(PROC_IOTC)iotc_month_5deg_longline.rds
	Rscript $<

# Year, flag
$(PROC_IOTC)iotc_year_5deg_longline_flag.rds: \
	$(ST_IOTC)aggregate_monthly_to_year_iotc_5deg_longline_flag.R \
	$(PROC_IOTC)iotc_month_5deg_longline_flag.rds
	Rscript $<

###############################
# WCPFC, purse seine
###############################

# Month 5 deg, quarter 1 deg, quarter 5 deg, and year 5 deg data not accounted
# for here

# Month
$(PROC_WCPFC)wcpfc_month_1deg_purseseine.rds: \
	$(ST_WCPFC)clean_wcpfc_month_1deg_purseseine.R \
	$(RAW_WCPFC)month_1deg_purseseine/month_1deg_purseseine.csv
	Rscript $<

# Year
$(PROC_WCPFC)wcpfc_year_1deg_purseseine.rds: \
	$(ST_WCPFC)aggregate_quarter_to_year_wcpfc_1deg_purseseine.R \
	$(RAW_WCPFC)quarter_1deg_purseseine_flag/quarter_1deg_purseseine_flag.csv
	Rscript $<

# Year, flag
$(PROC_WCPFC)wcpfc_year_1deg_purseseine_flag.rds: \
	$(ST_WCPFC)aggregate_quarter_to_year_wcpfc_1deg_purseseine_flag.R \
	$(RAW_WCPFC)quarter_1deg_purseseine_flag/quarter_1deg_purseseine_flag.csv
	Rscript $<

###############################
# WCPFC, longline
###############################

# Month
$(PROC_WCPFC)wcpfc_month_5deg_longline.rds: \
	$(ST_WCPFC)clean_wcpfc_month_5deg_longline.R \
	$(RAW_WCPFC)month_5deg_longline/month_5deg_longline.csv
	Rscript $<

# Month, flag
$(PROC_WCPFC)wcpfc_month_5deg_longline_flag.rds: \
	$(ST_WCPFC)clean_wcpfc_month_5deg_longline_flag.R \
	$(RAW_WCPFC)month_5deg_longline_flag/month_5deg_longline_flag.csv
	Rscript $<

# Year, flag
$(PROC_WCPFC)wcpfc_year_5deg_longline_flag.rds: \
	$(ST_WCPFC)clean_wcpfc_year_5deg_longline_flag.R \
	$(RAW_WCPFC)year_5deg_longline_flag/year_5deg_longline_flag.csv
	Rscript $<

###############################
# Bind data, purse seine
###############################

# Month
$(DATA_BIND)allrfmo_month_1deg_purseseine.rds: \
	$(PROC_BIND)bind_monthly_1deg_purseseine.R \
	$(PROC_IATTC)iattc_month_1deg_purseseine.rds \
	$(PROC_ICCAT)iccat_month_1deg_purseseine.rds \
	$(PROC_WCPFC)wcpfc_month_1deg_purseseine.rds \
	$(PROC_IOTC)iotc_month_1deg_purseseine.rds
	Rscript $<

# Year
$(DATA_BIND)allrfmo_year_1deg_purseseine.rds: \
	$(PROC_BIND)bind_yearly_1deg_purseseine.R \
	$(PROC_IATTC)iattc_year_1deg_purseseine.rds \
	$(PROC_ICCAT)iccat_year_1deg_purseseine.rds \
	$(PROC_WCPFC)wcpfc_year_1deg_purseseine.rds \
	$(PROC_IOTC)iotc_year_1deg_purseseine.rds
	Rscript $<

# Year, flag
$(DATA_BIND)allrfmo_year_1deg_purseseine_flag.rds: \
	$(PROC_BIND)bind_yearly_1deg_purseseine_flag.R \
	$(PROC_IATTC)iattc_year_1deg_purseseine_flag.rds \
	$(PROC_ICCAT)iccat_year_1deg_purseseine_flag.rds \
	$(PROC_WCPFC)wcpfc_year_1deg_purseseine_flag.rds \
	$(PROC_IOTC)iotc_year_1deg_purseseine_flag.rds
	Rscript $<

# Detect overlap month
$(DATA_BIND)monthly_overlap_cells_purseseine.rds: \
	$(PROC_BIND)detect_overlaps_purseseine.R \
	$(DATA_BIND)allrfmo_month_1deg_purseseine.rds
	Rscript $<

# Detect overlap year
$(DATA_BIND)yearly_overlap_cells_purseseine.rds: \
	$(PROC_BIND)detect_overlaps_purseseine.R \
	$(DATA_BIND)allrfmo_year_1deg_purseseine.rds
	Rscript $<

# Detect overlap year flag
$(DATA_BIND)yearly_flag_overlap_cells_purseseine.rds: \
	$(PROC_BIND)detect_overlaps_purseseine.R \
	$(DATA_BIND)allrfmo_year_1deg_purseseine_flag.rds
	Rscript $<

###############################
# Bind data, longline
###############################

# Month
$(DATA_BIND)allrfmo_month_5deg_longline.rds: \
	$(PROC_BIND)bind_monthly_5deg_longline.R \
	$(PROC_IATTC)iattc_month_5deg_longline.rds \
	$(PROC_ICCAT)iccat_month_5deg_longline.rds \
	$(PROC_WCPFC)wcpfc_month_5deg_longline.rds \
	$(PROC_IOTC)iotc_month_5deg_longline.rds
	Rscript $<

# Month, flag
$(DATA_BIND)allrfmo_month_5deg_longline_flag.rds: \
	$(PROC_BIND)bind_monthly_5deg_longline_flag.R \
	$(PROC_IATTC)iattc_month_5deg_longline_flag.rds \
	$(PROC_ICCAT)iccat_month_5deg_longline_flag.rds \
	$(PROC_WCPFC)wcpfc_month_5deg_longline_flag.rds \
	$(PROC_IOTC)iotc_month_5deg_longline_flag.rds
	Rscript $<

# Year
$(DATA_BIND)allrfmo_year_5deg_longline.rds: \
	$(PROC_BIND)bind_yearly_5deg_longline.R \
	$(PROC_IATTC)iattc_year_5deg_longline.rds \
	$(PROC_ICCAT)iccat_year_5deg_longline.rds \
	$(PROC_WCPFC)wcpfc_year_5deg_longline_flag.rds \
	$(PROC_IOTC)iotc_year_5deg_longline.rds
	Rscript $<

# Year, flag
$(DATA_BIND)allrfmo_year_5deg_longline_flag.rds: \
	$(PROC_BIND)bind_yearly_5deg_longline_flag.R \
	$(PROC_IATTC)iattc_year_5deg_longline_flag.rds \
	$(PROC_ICCAT)iccat_year_5deg_longline_flag.rds \
	$(PROC_WCPFC)wcpfc_year_5deg_longline_flag.rds \
	$(PROC_IOTC)iotc_year_5deg_longline_flag.rds
	Rscript $<

# Detect overlap month
$(DATA_BIND)monthly_overlap_cells_longline.rds: \
	$(PROC_BIND)detect_overlaps_longline.R \
	$(DATA_BIND)allrfmo_month_5deg_longline.rds
	Rscript $<

# Detect overlap month, flag
$(DATA_BIND)monthly_flag_overlap_cells_longline.rds: \
	$(PROC_BIND)detect_overlaps_longline.R \
	$(DATA_BIND)allrfmo_month_5deg_longline_flag.rds
	Rscript $<

# Detect overlap year
$(DATA_BIND)yearly_overlap_cells_longline.rds: \
	$(PROC_BIND)detect_overlaps_longline.R \
	$(DATA_BIND)allrfmo_year_5deg_longline.rds
	Rscript $<

# Detect overlap year flag
$(DATA_BIND)yearly_flag_overlap_cells_longline.rds: \
	$(PROC_BIND)detect_overlaps_longline.R \
	$(DATA_BIND)allrfmo_year_5deg_longline_flag.rds
	Rscript $<

###############################
# Harmonize data, purse seine
###############################

$(OUT)allrfmo_month_1deg_purseseine.rds: \
	$(PROC_HARM)harmonize_monthly_1deg_purseseine.R \
	$(DATA_BIND)allrfmo_month_1deg_purseseine.rds \
	$(DATA_BIND)monthly_overlap_cells_purseseine.rds
	Rscript $<

$(OUT)allrfmo_year_1deg_purseseine.rds: \
	$(PROC_HARM)harmonize_yearly_1deg_purseseine.R \
	$(DATA_BIND)allrfmo_year_1deg_purseseine.rds \
	$(DATA_BIND)yearly_overlap_cells_purseseine.rds
	Rscript $<

$(OUT)allrfmo_year_1deg_purseseine_flag.rds: \
	$(PROC_HARM)harmonize_yearly_1deg_purseseine_flag.R \
	$(DATA_BIND)allrfmo_year_1deg_purseseine_flag.rds \
	$(DATA_BIND)yearly_flag_overlap_cells_purseseine.rds
	Rscript $<

###############################
# Harmonize data, longline
###############################

$(OUT)allrfmo_month_5deg_longline.rds: \
	$(PROC_HARM)harmonize_monthly_5deg_longline.R \
	$(DATA_BIND)allrfmo_month_5deg_longline.rds \
	$(DATA_BIND)monthly_overlap_cells_longline.rds
	Rscript $<

$(OUT)allrfmo_month_5deg_longline_flag.rds: \
	$(PROC_HARM)harmonize_monthly_5deg_longline_flag.R \
	$(DATA_BIND)allrfmo_month_5deg_longline_flag.rds \
	$(DATA_BIND)monthly_flag_overlap_cells_longline.rds
	Rscript $<

$(OUT)allrfmo_year_5deg_longline.rds: \
	$(PROC_HARM)harmonize_yearly_5deg_longline.R \
	$(DATA_BIND)allrfmo_year_5deg_longline.rds \
	$(DATA_BIND)yearly_overlap_cells_longline.rds
	Rscript $<

$(OUT)allrfmo_year_5deg_longline_flag.rds: \
	$(PROC_HARM)harmonize_yearly_5deg_longline_flag.R \
	$(DATA_BIND)allrfmo_year_5deg_longline_flag.rds \
	$(DATA_BIND)yearly_flag_overlap_cells_longline.rds
	Rscript $<

###############################
# WCPFC Length Data
###############################

$(OUT)wcpfc_length_data.rds: \
	$(ST_WCPFC)clean_wcpfc_length_data.R \
	$(RAW_WCPFC)length_data/wcpfc_length_data.csv
	Rscript $<

###############################
# Export harmonized datasets to CSV
###############################

$(OUT)%.csv: $(OUT)%.rds
	Rscript -e "write.csv(readRDS('$<'), '$@', row.names = FALSE)"

## DAG
dag: dag.png

# draw makefile dag
dag.png: Makefile
	LANG=C make -np | python3 make_p_to_json.py | python3 json_to_dot.py | dot -Tpng >| dag.png

