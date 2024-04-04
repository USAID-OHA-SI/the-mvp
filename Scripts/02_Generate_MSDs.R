# PURPOSE: the-mvp
# AUTHOR:  Baboyma Kagniniwa | USAID/OHA/SIEI/SI
# PURPOSE: Test cases for DDC/CFI & MVP
# REF ID:  7ac6ff3b
# LICENSE: MIT
# DATE:    2024-03-28
# UPDATE:  2024-03-28
# NOTES:   Use only fake data

# Libraries ====

  library(tidyverse)
  library(glamr)
  library(gophr)
  library(grabr)
  library(themask)
  
  source("./Scripts/N00_Utilities.R")

# LOCALS & SETUP ====

# Set Params

# Set paths

  dir_data   <- "Data"
  dir_dataout <- "Dataout"
  dir_images  <- "Images"
  dir_graphics  <- "Graphics"
  
  dir_mer <- glamr::si_path("path_msd")

# Files

  msk_available()
  
  #msk_create()
  
  msk_download(
    folderpath = dir_mer,
    tag = "latest",
    launch = F
  )

  file_t_psnu <- return_latest(
    folderpath = dir_mer,
    pattern = "^MER.*TRAINING.*_PSNU_IM_FY.*.zip"
  )
  
  get_metadata(file_t_psnu)
  
  meta <- metadata
  
# DATA 

  df_psnu_im <- file_t_psnu %>% read_psd()
  
  df_psnu_im %>% glimpse()
  
  df_psnu_im %>% distinct(fiscal_year)

# MUNGE

  
# EXPORT 
  
  # Lastest fiscal year
  df_psnu_im %>% 
    filter(fiscal_year == meta$curr_fy) %>% 
    write_csv(na = "",
              file = file_t_psnu %>% 
                basename() %>% 
                str_replace("FY\\d{2}-\\d{2}", meta$curr_fy_lab) %>% 
                str_replace(".zip$", ".csv") %>% 
                file.path(dir_dataout, .))
