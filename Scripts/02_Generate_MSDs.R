# PURPOSE: the-mvp
# AUTHOR:  Baboyma Kagniniwa | USAID/OHA/SIEI/SI
# PURPOSE: Test cases for DDC/CFI & MVP
# REF ID:  7ac6ff3b
# LICENSE: MIT
# DATE:    2024-03-28
# UPDATE:  2024-04-04
# NOTES:   Use only fake data

# Libraries ====

  library(tidyverse)
  library(glamr)
  library(gophr)
  library(grabr)
  library(themask)
  library(AzureStor)
  
  source("./Scripts/N00_Utilities.R")

# LOCALS & SETUP ====

# Set Params

# Set paths

  dir_data   <- "Data"
  dir_dataout <- "Dataout"
  dir_images  <- "Images"
  dir_graphics  <- "Graphics"
  
  dir_mer <- glamr::si_path("path_msd")
  dir_train <- fs::dir_create(dir_mer, "TRAINING")
  
  dir_mer %>% fs::dir_ls()
  
# Azure Account
  
  acct <- get_account(name = "azure-cfi-store-test")
  
  cnt_name <- "samplemsds"
  
  blob_key <- storage_endpoint(
    endpoint = glue::glue("https://{acct$account}.blob.core.windows.net"),
    key = acct$account_key
  )

# Files

  themask::msk_available()
  
  #themask::msk_create()
  
  # Download latest Training dataset
  msk_download(
    folderpath = dir_train,
    tag = "latest",
    launch = F
  )

  file_t_psnu <- return_latest(
    folderpath = dir_train,
    pattern = "^MER.*TRAINING.*_PSNU_IM_FY.*.zip"
  )
  
  meta <- get_metadata(file_t_psnu)
  
# DATA 

  df_psnu_im <- file_t_psnu %>% read_psd()
  
  df_psnu_im %>% glimpse()
  
  df_psnu_im %>% distinct(fiscal_year)

# MUNGE

  
# EXPORT 
  
  # Split files by fiscal year
  
  df_psnu_im %>% 
    distinct(fiscal_year) %>% 
    pull() %>% 
    walk(function(.fy){
      df_psnu_im %>% 
        filter(fiscal_year == .fy) %>% 
        write_csv(na = "",
                  file = file_t_psnu %>% 
                    basename() %>% 
                    str_replace("FY\\d{2}-\\d{2}", paste0("FY", str_sub(.fy, 3, 4))) %>% 
                    str_replace(".zip$", ".csv") %>% 
                    file.path(dir_dataout, .))
    })
  
# Access files from Azure Storage 

  cont <- storage_container(endpoint = blob_key, name = cnt_name)
  
  curr_blobs <- list_storage_files(cont)
  
  curr_blobs %>% glimpse()
  
  curr_blobs %>% 
    filter(str_detect(name, "^outgoing\\/MER_S.*PSNU_IM_.*.csv")) %>% 
    pull(name) %>% 
    first() %>% 
    storage_download(container = cont, 
                     src = ., dest = glue::glue("{dir_data}/{basename(.)}"))

    
# Upload files to Azure Storage
  
  dir_dataout %>% 
    fs::dir_ls() %>% 
    storage_multiupload(container = cont,
                        src = .,
                        dest = file.path("incoming", basename(.)))
