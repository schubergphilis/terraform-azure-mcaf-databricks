terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "network" {
  source  = "github.com/schubergphilis/terraform-azure-mcaf-network"
  version = "1.0.0"

  vnet = {
    name                = "databricks-vnet"
    resource_group_name = var.resource_group_name
    location            = var.location
    address_space       = ["10.1.0.0/16"]
  }

  subnets = {
    private_subnet = {
      name           = "databricks-private-subnet"
      address_prefix = "10.1.1.0/24"
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
    }
    public_subnet = {
      name           = "databricks-public-subnet"
      address_prefix = "10.1.2.0/24"
      service_endpoints = []
    }
  }
}

module "databricks" {
  source  = "github.com/schubergphilis/terraform-azure-mcaf-databricks"
  version = "0.0.1"

  workspace = {
    name                = "my-databricks-workspace"
    resource_group_name = var.resource_group_name
    location            = var.location
    sku                 = "premium"
    enable_private_link = true
  }

  network = {
    vnet_id             = module.network.vnet_id
    private_subnet_id   = module.network.subnets["private_subnet"].id
    public_subnet_id    = module.network.subnets["public_subnet"].id
    nsg_id              = module.network.nsg_id
    private_endpoint_ids = module.network.private_endpoint_ids
  }

  managed_identity = {
    enabled = true
    name    = "my-databricks-identity"
  }
}

output "databricks_workspace_url" {
  description = "The URL of the Databricks workspace"
  value       = module.databricks.databricks_workspace_url
}