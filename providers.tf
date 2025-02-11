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
}

provider "databricks" {
  alias     = "workspace"
  host      = azurerm_databricks_workspace.this.workspace_url
  auth_type = "azure-cli"
}