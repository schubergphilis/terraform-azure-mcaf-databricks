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

output "metastore_id" {
  value       = var.metastore_id
  description = "The metastore ID assigned to the Databricks workspace."
}

output "private_subnet_nsg_id" {
  value       = azurerm_network_security_group.private.id
  description = "The ID of the Network Security Group (NSG) associated with the private subnet."
}

output "public_subnet_nsg_id" {
  value       = azurerm_network_security_group.public.id
  description = "The ID of the Network Security Group (NSG) associated with the public subnet."
}