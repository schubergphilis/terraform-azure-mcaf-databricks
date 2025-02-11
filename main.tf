resource "azurerm_databricks_workspace" "this" {
  name                                                = "${var.prefix}-adb-workspace"
  resource_group_name                                 = var.resource_group_name
  location                                            = var.location
  sku                                                 = var.databricks_sku
  managed_disk_cmk_key_vault_key_id                   = var.managed_disk_key_id
  managed_services_cmk_key_vault_key_id               = var.managed_services_key_id
  managed_disk_cmk_rotation_to_latest_version_enabled = true
  customer_managed_key_enabled                        = true
  infrastructure_encryption_enabled                   = true
  public_network_access_enabled                       = false
  network_security_group_rules_required               = "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = var.vnet_id
    public_subnet_name                                   = var.public_subnet_name
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_network_security_group_association_id  = var.public_subnet_nsg_id
    private_subnet_network_security_group_association_id = var.private_subnet_nsg_id
  }

  tags = merge(
    {
      "Resource Type" = "Databricks Workspace"
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "this" {
  depends_on = [azurerm_key_vault_access_policy.databricks]

  workspace_id     = azurerm_databricks_workspace.this.workspace_id
  key_vault_key_id = var.managed_disk_key_id
}

resource "azurerm_key_vault_access_policy" "databricks" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_databricks_workspace.this.storage_account_identity.0.tenant_id
  object_id    = azurerm_databricks_workspace.this.storage_account_identity.0.principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
} 

resource "azurerm_key_vault_access_policy" "managed" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = var.databricks_app_object_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "databricks_metastore_assignment" "this" {
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  metastore_id = var.metastore_id
}