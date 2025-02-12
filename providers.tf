terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0" # Force rollback to 3.x
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  use_msi         = true
}

provider "databricks" {
  alias     = "workspace"
  host      = var.databricks_host
  auth_type = "azure-cli"
}