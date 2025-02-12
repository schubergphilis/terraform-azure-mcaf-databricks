resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-network.git"

  resource_group = {
    name     = var.resource_group_name
    location = var.location
  }

  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnets            = var.subnets
}

module "storage_account" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-storage-account.git"

  name                     = var.storage_account_name
  resource_group_name      = module.network.resource_group.name # 👈 Dynamically fetch resource group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags                     = var.tags

  # Use Key Vault CMK
  cmk_key_vault_id = module.keyvault.key_vault_id
  cmk_key_name     = module.keyvault.cmkrsa_key_name

  # Network Integration
  network_configuration = {
    public_network_access_enabled   = false
    https_traffic_only_enabled      = true
    allow_nested_items_to_be_public = false
    default_action                  = "Deny"
    virtual_network_subnet_ids = [
      lookup({ for subnet in module.network.all_subnets : subnet.name => subnet.id }, "private-subnet", null),
      lookup({ for subnet in module.network.all_subnets : subnet.name => subnet.id }, "public-subnet", null)
    ]
    ip_rules = []
    bypass   = ["AzureServices"]
  }
}

module "keyvault" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-core.git"

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

# **Create Databricks Managed Identity**
resource "azurerm_user_assigned_identity" "databricks_mid" {
  name                = var.databricks_mid_name
  resource_group_name = var.databricks_mid_resource_group
  location            = var.location
}

# **Assign Key Vault Role to Databricks Managed Identity**
resource "azurerm_role_assignment" "databricks_mid_kv" {
  scope                = module.keyvault.key_vault_id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.databricks_mid.principal_id
}

# **Grant Key Vault Access Policy for Databricks Managed Identity**
resource "azurerm_key_vault_access_policy" "databricks_mid" {
  key_vault_id = module.keyvault.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.databricks_mid.principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

module "databricks" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-databricks.git?ref=develop"

  prefix                        = var.prefix
  databricks_workspace_name     = var.databricks_workspace_name
  databricks_sku                = var.databricks_sku
  vnet_id                       = module.network.id
  private_subnet_id             = lookup({ for subnet in module.network.all_subnets : subnet.name => subnet.id }, "private-subnet", null)
  public_subnet_id              = lookup({ for subnet in module.network.all_subnets : subnet.name => subnet.id }, "public-subnet", null)
  private_subnet_name           = "private-subnet"
  public_subnet_name            = "public-subnet"
  private_subnet_nsg_id         = module.databricks.private_subnet_nsg_id
  public_subnet_nsg_id          = module.databricks.public_subnet_nsg_id
  resource_group_name           = var.resource_group_name
  location                      = var.location
  key_vault_id                  = module.keyvault.key_vault_id
  managed_disk_key_id           = module.keyvault.cmkrsa_id
  managed_services_key_id       = module.keyvault.cmkrsa_resource_versionless_id
  managed_identity_id           = azurerm_user_assigned_identity.databricks_mid.id
  tenant_id                     = var.tenant_id
  subscription_id               = var.subscription_id
  metastore_id                  = var.metastore_id
  tags                          = var.tags
  databricks_mid_resource_group = var.databricks_mid_resource_group
}

# **Ensure Databricks Workspace is Created Before Fetching Data**
data "azurerm_databricks_workspace" "this" {
  name                = module.databricks.databricks_workspace_name
  resource_group_name = var.resource_group_name

  depends_on = [module.databricks] # Ensure it runs only after Databricks is created
}

output "databricks_workspace_url" {
  value       = module.databricks.databricks_workspace_url
  description = "The URL of the Databricks workspace."
}