resource "azurerm_databricks_workspace" "this" {
  name                = var.workspace.name
  resource_group_name = var.workspace.resource_group_name
  location            = var.workspace.location
  sku                 = var.workspace.sku

  public_network_access_enabled = !var.workspace.enable_private_link

  tags = merge(
    var.tags,
    {
      "Resource Type" = "Databricks Workspace"
    }
  )
}

resource "azurerm_user_assigned_identity" "this" {
  count               = var.managed_identity.enabled ? 1 : 0
  name                = var.managed_identity.name
  resource_group_name = var.workspace.resource_group_name
  location            = var.workspace.location

  tags = merge(
    var.tags,
    {
      "Resource Type" = "User Assigned Identity"
    }
  )
}