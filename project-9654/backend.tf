terraform {
  backend "azurerm" {
    resource_group_name  = "9654-tfstate-RG"
    storage_account_name = "9654tfstatesukrutha"
    container_name       = "tfstatefiles"
    key                  = "project-9654.tfstate"
  }
}
