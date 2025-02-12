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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >= 1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace) | resource |
| [azurerm_databricks_workspace_root_dbfs_customer_managed_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace_root_dbfs_customer_managed_key) | resource |
| [azurerm_key_vault_access_policy.databricks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [databricks_metastore_assignment.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment) | resource |
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/databricks_workspace) | data source |
| [azurerm_user_assigned_identity.databricks_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_host"></a> [databricks\_host](#input\_databricks\_host) | The Databricks workspace host URL. | `string` | `""` | no |
| <a name="input_databricks_sku"></a> [databricks\_sku](#input\_databricks\_sku) | The SKU tier for Databricks (standard, premium). | `string` | n/a | yes |
| <a name="input_databricks_workspace_name"></a> [databricks\_workspace\_name](#input\_databricks\_workspace\_name) | The name of the Databricks workspace. | `string` | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Azure Key Vault. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be deployed. | `string` | n/a | yes |
| <a name="input_managed_disk_key_id"></a> [managed\_disk\_key\_id](#input\_managed\_disk\_key\_id) | The Key Vault key ID used to encrypt Databricks-managed disks. | `string` | n/a | yes |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | The ID of the user-assigned managed identity for Databricks (if applicable). | `string` | `""` | no |
| <a name="input_managed_services_key_id"></a> [managed\_services\_key\_id](#input\_managed\_services\_key\_id) | The Key Vault key ID used to encrypt Databricks-managed services. | `string` | n/a | yes |
| <a name="input_metastore_id"></a> [metastore\_id](#input\_metastore\_id) | The ID of the Databricks metastore to assign to the workspace. | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A prefix used for naming resources. | `string` | n/a | yes |
| <a name="input_private_subnet_name"></a> [private\_subnet\_name](#input\_private\_subnet\_name) | The name of the private subnet for Databricks. | `string` | n/a | yes |
| <a name="input_private_subnet_nsg_id"></a> [private\_subnet\_nsg\_id](#input\_private\_subnet\_nsg\_id) | The ID of the Network Security Group (NSG) associated with the private subnet. | `string` | n/a | yes |
| <a name="input_public_subnet_name"></a> [public\_subnet\_name](#input\_public\_subnet\_name) | The name of the public subnet for Databricks. | `string` | n/a | yes |
| <a name="input_public_subnet_nsg_id"></a> [public\_subnet\_nsg\_id](#input\_public\_subnet\_nsg\_id) | The ID of the Network Security Group (NSG) associated with the public subnet. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The Azure resource group where resources will be created. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Azure subscription ID. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure tenant ID. | `string` | n/a | yes |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | The ID of the Virtual Network where Databricks will be deployed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databricks_workspace_id"></a> [databricks\_workspace\_id](#output\_databricks\_workspace\_id) | The ID of the created Databricks workspace. |
| <a name="output_databricks_workspace_name"></a> [databricks\_workspace\_name](#output\_databricks\_workspace\_name) | The name of the Databricks workspace. |
| <a name="output_databricks_workspace_url"></a> [databricks\_workspace\_url](#output\_databricks\_workspace\_url) | The URL of the Databricks workspace. |
| <a name="output_metastore_id"></a> [metastore\_id](#output\_metastore\_id) | The metastore ID assigned to the Databricks workspace. |
<!-- END_TF_DOCS -->