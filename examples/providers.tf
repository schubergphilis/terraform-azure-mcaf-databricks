terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_msi = true
  subscription_id = var.subscription_id
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}