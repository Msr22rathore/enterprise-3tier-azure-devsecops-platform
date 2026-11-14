terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate22"
    container_name       = "tfstate"
    key                  = "dev.tfstate"

    use_azuread_auth = true
  }
}