resource "azurerm_databricks_workspace" "this" {
  name                                  = "${var.prefix}-adb-workspace"
  resource_group_name                   = var.resource_group_name
  location                              = var.location
  sku                                   = var.databricks_sku
  managed_disk_cmk_key_vault_key_id     = var.managed_disk_key_id
  managed_services_cmk_key_vault_key_id = var.managed_services_key_id
  customer_managed_key_enabled          = true
  infrastructure_encryption_enabled     = true
  public_network_access_enabled         = false
  network_security_group_rules_required = "NoAzureDatabricksRules"

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

# Fetch Databricks Workspace details dynamically
data "azurerm_databricks_workspace" "this" {
  name                = azurerm_databricks_workspace.this.name
  resource_group_name = var.resource_group_name
}

# Fetch Databricks Managed Identity (if applicable)
data "azurerm_user_assigned_identity" "databricks_identity" {
  count               = var.managed_identity_id != "" ? 1 : 0
  name                = basename(var.managed_identity_id)
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_access_policy" "databricks" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = var.managed_identity_id != "" ? var.managed_identity_id : data.azurerm_user_assigned_identity.databricks_identity[0].principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "databricks_metastore_assignment" "this" {
  count        = var.metastore_id != "" ? 1 : 0
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  metastore_id = var.metastore_id
}