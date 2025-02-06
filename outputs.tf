output "databricks_workspace_id" {
  description = "The ID of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.id
}

output "databricks_workspace_url" {
  description = "The URL of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "managed_identity_id" {
  description = "The ID of the managed identity if created"
  value       = try(azurerm_user_assigned_identity.this[0].id, null)
}

output "managed_identity_principal_id" {
  description = "The principal ID of the managed identity if created"
  value       = try(azurerm_user_assigned_identity.this[0].principal_id, null)
}