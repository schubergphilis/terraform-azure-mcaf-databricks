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
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-databricks?ref=develop"

  prefix                   = var.prefix
  vnet_id                  = module.network.id
  private_subnet_name      = module.network.subnets["private_subnet"].name
  public_subnet_name       = module.network.subnets["public_subnet"].name
  private_subnet_nsg_id    = module.network.all_network_security_groups["private_subnet"].id
  public_subnet_nsg_id     = module.network.all_network_security_groups["public_subnet"].id
  resource_group_name      = var.resource_group_name
  location                 = var.location
  databricks_host          = var.databricks_host
  databricks_token         = var.databricks_token
  key_vault_id             = module.keyvault.key_vault_id
  managed_disk_key_id      = module.keyvault.cmkrsa_id
  managed_services_key_id  = module.keyvault.cmkrsa_resource_versionless_id
  tenant_id                = var.tenant_id
  databricks_app_object_id = var.databricks_app_object_id
  metastore_id             = var.metastore_id
  tags                     = var.tags
}