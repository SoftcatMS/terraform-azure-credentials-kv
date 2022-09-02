terraform {
  required_version = ">=1.0.0"

  backend "azurerm" {
    resource_group_name  = "rg-terraform-modules-state"
    storage_account_name = "softcatmodulestate"
    container_name       = "tf-modules-azure-credentials-kv-advanced"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
