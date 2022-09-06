terraform {
  required_version = ">=1.0.0"

  backend "azurerm" {
    resource_group_name  = "rg-terraform-modules-state"
    storage_account_name = "softcatmodulestate"
    container_name       = "tf-modules-azure-credentials-kv-basic"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
