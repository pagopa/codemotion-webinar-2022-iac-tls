terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<= 2.99.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.16.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "= 0.2.2"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}
