# PROJECT: the-mvp
# AUTHOR:  Baboyma Kagniniwa | USAID/OHA/SIEI/SI
# PURPOSE: Parse out MDS into data and refs
# REF ID:  b60144d1 
# LICENSE: MIT
# DATE:    2024-04-04
# UPDATE:  2024-04-04
# NOTES:   Testing CFI flows

# Libraries ====
  
  library(tidyverse)
  library(glamr)
  library(gophr)
  library(grabr)
  library(themask)
  library(AzureStor)
  library(glue)
  
  source("./Scripts/N00_Utilities.R")
  
# LOCALS & SETUP ====

  # Set Params

  ref_id <- "b8140e7e"
  agency <- "USAID"
  cntry <- "Nigeria"
  cntry_uid <- get_ouuid(cntry)  
  
  # Set paths  
  
  dir_data   <- "Data"
  dir_dataout <- "Dataout"
  dir_images  <- "Images"
  dir_graphics  <- "Graphics"
   
  dir_mer <- glamr::si_path("path_msd")
  
  dir_mer %>% fs::dir_ls(all=T)
  
  dir_train <- fs::dir_create(dir_mer, "TRAINING")
  
  dir_train %>% fs::dir_ls()
  
  # Files 
  
  file_site1 <- si_path() %>% return_latest(glue("Site_IM_FY15-.*_{cntry}"))
  file_site2 <- si_path() %>% return_latest(glue("Site_IM_FY22-.*_{cntry}"))
    
  meta <- get_metadata(file_site1)
    
# Functions  =====
  
# FAKE DATA =====
  
  #file_site1 %>% msk_create(output_folder = dir_train)
  #file_site2 %>% msk_create(output_folder = dir_train)
  
# LOAD DATA =====

  df_msd <- file_site2 %>% read_psd()
  
  
# Build Metadata
  
  df_msd %>% glimpse()
  
  # df_msd %>% 
  #   names() %>% 
  #   clipr::write_clip()
  
  msd_sites <- list(
    orgs = c(
      #"fiscal_year", # Consider adding FY - Use to pivot psnu pre/post COP22
      "orgunituid",
      "sitename",
      "sitetype",
      "operatingunit",
      "operatingunituid",
      "country",
      "snu1",
      "snu1uid",
      "snu2",
      "snu2uid",
      "cop22_psnu",
      "cop22_psnuuid",
      "cop22_snuprioritization",
      "psnu",
      "psnuuid",
      "snuprioritization",
      "typemilitary",
      "dreams",
      "communityuid",
      "community",
      "facilityuid",
      "facility"
    ),
    orgs_mil = c( 
      "fiscal_year",
      "orgunituid",
      "typemilitary"
    ),
    orgs_dreams = c(
      "fiscal_year",
      "orgunituid",
      "dreams"
    ),
    mechs = c(
      "fiscal_year",
      "mech_code",
      "mech_name",
      "prime_partner_name",
      "prime_partner_duns",
      "prime_partner_uei",
      "is_indigenous_prime_partner",
      "award_number",
      "funding_agency"
    ),
    ages = c(
      "fiscal_year",
      "indicator", 
      "numeratordenom",
      "indicatortype",
      "standardizeddisaggregate", # Age disaggs only
      "categoryoptioncomboname",
      "use_for_age", # For TRUE only
      "ageasentered",
      "age_2018",
      "age_2019",
      "trendscoarse",
      "target_age_2024"
    ),
    mods = c(
      "fiscal_year",
      "indicator", # Filter for HTS only
      "numeratordenom",
      "indicatortype",
      "standardizeddisaggregate",
      "modality",
      "target_modality_2024"
    ),
    measure = c(
      "fiscal_year",
      "indicator",
      "numeratordenom",
      "indicatortype",
      "standardizeddisaggregate",
      "categoryoptioncomboname",
      "source_name",
      "safe_for_net_new",
      "safe_for_vlc"
    ),
    data = c(
      "fiscal_year",
      "orgunituid",
      "mech_code",
      "indicator",
      "numeratordenom",
      "indicatortype",
      "standardizeddisaggregate",
      "categoryoptioncomboname",
      #"use_for_age",
      "ageasentered",
      #"age_2018",
      #"age_2019",
      #"trendscoarse",
      #"target_age_2024",
      "sex",
      "statushiv",
      "statustb",
      "statuscx",
      "hiv_treatment_status",
      "otherdisaggregate",
      "otherdisaggregate_sub",
      "modality",
      #"target_modality_2024",
      "targets",
      "qtr1",
      "qtr2",
      "qtr3",
      "qtr4",
      "cumulative"
      #"source_name",
      #"safe_for_net_new",
      #"safe_for_vlc"
    )
  )
  
# UNPACK MDS
  
  df_msd_parts <- msd_sites %>% 
    names() %>% 
    map(function(.name){
      
      # Extract a subset
      .data <- df_msd %>% 
        select(any_of(msd_sites[[.name]])) 
      
      # Age bands
      if (.name == "ages") 
        .data <- .data %>% 
          filter(use_for_age == 'Y')
      
      # HTS Modalities
      if (.name == "mods") 
        .data <- .data %>% 
          filter(str_detect(indicator, "^HTS"),
                 !is.na(modality)) %>% 
          distinct_all()
      
      # Data 
      if (.name == "data") 
        .data <- .data %>% 
          mutate(fy = fiscal_year) %>% 
          reshape_msd() %>% 
          relocate(fy, .before = 1)

      # Distinct Values
      .data %>% distinct_all()  
      
    }) %>% 
    set_names(nm = names(msd_sites))
  
  df_msd_parts$orgs
  df_msd_parts$ages
  df_msd_parts$mods
  df_msd_parts$measure
  df_msd_parts$data
  

# MUNGE =====
  
  
  

  
# VIZ =====

  

# OUTPUTS =====

