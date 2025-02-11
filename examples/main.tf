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
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-storage-account.git?ref=main"

  name                = var.storage_account_name
  resource_group_name = module.network.resource_group.name # 👈 Dynamically fetch resource group
  location           = var.location
  account_tier        = "Standard"
  account_replication_type = "LRS"
  account_kind        = "StorageV2"
  tags               = var.tags

  # Use Key Vault CMK
  cmk_key_vault_id    = module.keyvault.key_vault_id
  cmk_key_name        = module.keyvault.cmkrsa_key_name

  # Network Integration
  network_configuration = {
    public_network_access_enabled   = false
    https_traffic_only_enabled      = true
    allow_nested_items_to_be_public = false
    default_action                  = "Deny"
    virtual_network_subnet_ids      = [
      module.network.subnets["private_subnet"].id,
      module.network.subnets["public_subnet"].id
    ]
    ip_rules = []
    bypass   = ["AzureServices"]
  }
}

module "keyvault" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-core.git?ref=main"

  location = var.location

  resource_group = {
    name     = module.network.resource_group.name # 👈 Dynamically fetch resource group
    location = var.location
  }

  key_vault = {
    name                     = var.keyvault_name
    sku                      = var.keyvault_sku
    soft_delete_enabled      = true
    purge_protection_enabled = true
    access_policies          = var.keyvault_access_policies
    cmk_keys_create          = true
    cmkrsa_key_name          = "cmk-disk-key"
    cmk_rotation_period      = "P90D"
    cmk_expiry_period        = "P2Y"
    cmk_notify_period        = "P30D"
  }
}

module "databricks" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-databricks.git?ref=develop"

  prefix                    = var.prefix
  databricks_workspace_name = var.databricks_workspace_name
  databricks_sku            = var.databricks_sku
  vnet_id                   = module.network.id # 👈 Reference VNet ID dynamically
  private_subnet_name       = module.network.subnets["private_subnet"].name
  public_subnet_name        = module.network.subnets["public_subnet"].name
  private_subnet_nsg_id     = module.network.all_network_security_groups["private_subnet"].id
  public_subnet_nsg_id      = module.network.all_network_security_groups["public_subnet"].id
  resource_group_name       = module.network.resource_group.name # 👈 Reference resource group dynamically
  location                  = var.location
  key_vault_id              = module.keyvault.key_vault_id
  managed_disk_key_id       = module.keyvault.cmkrsa_id
  managed_services_key_id   = module.keyvault.cmkrsa_resource_versionless_id
  managed_identity_id       = var.managed_identity_id
  tenant_id                 = var.tenant_id
  subscription_id           = var.subscription_id
  databricks_host           = module.databricks.databricks_workspace_url
  metastore_id              = var.metastore_id
  tags                      = var.tags
}