variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "resource_group_name" {
  description = "The Azure resource group where the Databricks workspace will be created"
  type        = string
}

variable "location" {
  description = "The Azure region where the Databricks workspace will be deployed"
  type        = string
}

variable "databricks_sku" {
  description = "The SKU tier for Databricks (standard, premium)"
  type        = string
  default     = "premium"
}

variable "managed_disk_key_id" {
  description = "The Key Vault key ID for managed disk encryption"
  type        = string
}

variable "managed_services_key_id" {
  description = "The Key Vault key ID for managed services encryption"
  type        = string
}

variable "vnet_id" {
  description = "The ID of the Virtual Network to attach Databricks to"
  type        = string
}

variable "public_subnet_name" {
  description = "The name of the public subnet"
  type        = string
}

variable "private_subnet_name" {
  description = "The name of the private subnet"
  type        = string
}

variable "public_subnet_nsg_id" {
  description = "The ID of the NSG associated with the public subnet"
  type        = string
}

variable "private_subnet_nsg_id" {
  description = "The ID of the NSG associated with the private subnet"
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault used for Databricks encryption"
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}

variable "databricks_app_object_id" {
  description = "The Object ID of the Databricks application for key vault access"
  type        = string
}

variable "metastore_id" {
  description = "The ID of the Databricks metastore to assign to the workspace"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "databricks_host" {
  description = "The Databricks workspace host URL"
  type        = string
}

variable "databricks_token" {
  description = "The authentication token for Databricks API access"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}

variable "client_id" {
  description = "The Azure client ID for authentication"
  type        = string
}

variable "client_secret" {
  description = "The Azure client secret for authentication"
  type        = string
  sensitive   = true
}
