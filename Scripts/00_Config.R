##
## USER CONFIGURATION
## 


# Check Azure Storage Package
pkg_azure_storage <- "AzureStor"

if (!glamr::package_check(pkg_azure_storage)) {
  remotes::install_github("Azure/AzureStor")
}

# Set up Azure Access

## Portal
portal <- "azure-cfi"

if (length(glamr::get_account(name = portal)) == 0) {
  glamr::set_account(name = portal, keys = c("host", "username", "password"))
}

## Storage Account
store <- "azure-cfi-store-test"

if (length(glamr::get_account(name = store)) == 0) {
  glamr::set_account(name = store, 
                     keys = c("account", "account_key", "connection"), update = T)
}




