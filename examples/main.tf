resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-network.git?ref=main"

  resource_group = {
    name     = var.resource_group_name
    location = var.location
  }

  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnets            = var.subnets
}

module "storage_account" {
  source                   = "git::https://github.com/schubergphilis/terraform-azure-mcaf-storage-account.git?ref=main"
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags                     = var.tags
}

module "keyvault" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-core.git?ref=main"

  location = var.location

  resource_group = {
    name     = var.resource_group_name
    location = var.location
  }

  key_vault = {
    name                     = var.keyvault_name
    sku                      = var.keyvault_sku
    soft_delete_enabled      = true
    purge_protection_enabled = false
    access_policies          = var.keyvault_access_policies
  }
}

module "databricks" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-databricks.git?ref=develop"

  prefix                  = var.prefix
  vnet_id                 = module.network.vnet_id
  private_subnet_name     = module.network.subnets["private_subnet"].name
  public_subnet_name      = module.network.subnets["public_subnet"].name
  private_subnet_nsg_id   = module.network.all_network_security_groups["private_subnet"].id
  public_subnet_nsg_id    = module.network.all_network_security_groups["public_subnet"].id
  resource_group_name     = var.resource_group_name
  location                = var.location
  key_vault_id            = module.keyvault.key_vault_id
  managed_disk_key_id     = module.keyvault.cmkrsa_id
  managed_services_key_id = module.keyvault.cmkrsa_resource_versionless_id
  managed_identity_id     = var.managed_identity_id
  tenant_id               = var.tenant_id
  subscription_id         = var.subscription_id
  databricks_host         = module.databricks.databricks_workspace_url
  databricks_app_object_id = module.databricks.databricks_app_object_id
  metastore_id            = var.metastore_id
  tags                    = var.tags
}

# Fetch Databricks Workspace details dynamically
data "azurerm_databricks_workspace" "this" {
  name                = module.databricks.databricks_workspace_name
  resource_group_name = var.resource_group_name
}

output "databricks_workspace_url" {
  value       = data.azurerm_databricks_workspace.this.workspace_url
  description = "The URL of the Databricks workspace."
}

output "databricks_app_object_id" {
  value       = data.azurerm_databricks_workspace.this.managed_resource_group_id
  description = "The Object ID of the Databricks Managed Identity."
}