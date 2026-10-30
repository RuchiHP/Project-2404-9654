terraform {
  backend "azurerm" {
    resource_group_name  = "2404-tfstate-RG"
    storage_account_name = "2404tfstateruchi"
    container_name       = "tfstatefiles"
    key                  = "project-2404-9654.tfstate"
  }
}
