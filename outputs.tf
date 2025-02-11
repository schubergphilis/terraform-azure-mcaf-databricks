output "databricks_workspace_id" {
  description = "The ID of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.id
}

output "databricks_workspace_url" {
  description = "The URL of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "databricks_metastore_assignment_id" {
  description = "The ID of the Databricks metastore assignment"
  value       = databricks_metastore_assignment.this.id
}

output "key_vault_access_policy_databricks_id" {
  description = "The ID of the Key Vault access policy for Databricks"
  value       = azurerm_key_vault_access_policy.databricks.id
}

output "key_vault_access_policy_managed_id" {
  description = "The ID of the Key Vault access policy for managed identity"
  value       = azurerm_key_vault_access_policy.managed.id
}
