output "databricks_workspace_id" {
  value       = azurerm_databricks_workspace.this.id
  description = "The ID of the created Databricks workspace."
}

output "databricks_workspace_url" {
  value       = azurerm_databricks_workspace.this.workspace_url
  description = "The URL of the Databricks workspace."
}

output "databricks_workspace_name" {
  value       = azurerm_databricks_workspace.this.name
  description = "The name of the Databricks workspace."
}

output "databricks_app_object_id" {
  value       = try(azurerm_databricks_workspace.this.identity.0.principal_id, null)
  description = "The Object ID of the Databricks managed identity."
}

output "metastore_id" {
  value       = var.metastore_id
  description = "The metastore ID assigned to the Databricks workspace."
}