# Terraform Azure Databricks Module

## Overview
This module provisions an **Azure Databricks** workspace while leveraging the **Azure Network Module** to configure virtual networks and subnets.

## Usage

```hcl
module "network" {
  source  = "github.com/schubergphilis/terraform-azure-mcaf-network"
  version = "x.y.z"
  
  vnet = {
    name                = "databricks-vnet"
    resource_group_name = "my-resource-group"
    location            = "West Europe"
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
  source  = "./modules/databricks"
  
  workspace = {
    name                = "my-databricks-workspace"
    resource_group_name = "my-resource-group"
    location            = "West Europe"
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
```

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `workspace` | object | Configuration for the Databricks workspace |
| `managed_identity` | object | Managed identity configuration |
| `network` | object | Network configuration provided by the Network module |
| `tags` | map(string) | Tags to apply to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `databricks_workspace_id` | The ID of the Databricks workspace |
| `databricks_workspace_url` | The URL of the Databricks workspace |
| `managed_identity_id` | The ID of the managed identity if created |
| `managed_identity_principal_id` | The principal ID of the managed identity if created |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Resources

- `azurerm_databricks_workspace`
- `azurerm_user_assigned_identity`

## Author
This module is maintained by **Your Name/Team**.
