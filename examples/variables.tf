variable "resource_group_name" {
  description = "The Azure resource group where resources will be created"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "vnet_name" {
  description = "The name of the Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network"
  type        = list(string)
}

variable "subnets" {
  description = "A map of subnet configurations"
  type = map(object({
    name              = string
    address_prefix    = string
    service_endpoints = list(string)
  }))
}

variable "keyvault_name" {
  description = "The name of the Azure Key Vault"
  type        = string
}

variable "keyvault_access_policies" {
  description = "A list of Key Vault access policies"
  type = list(object({
    tenant_id           = string
    object_id           = string
    key_permissions     = list(string)
    secret_permissions  = list(string)
    certificate_permissions = list(string)
  }))
}

variable "databricks_workspace_name" {
  description = "The name of the Databricks workspace"
  type        = string
}

variable "databricks_sku" {
  description = "The SKU tier for Databricks (standard, premium)"
  type        = string
}

variable "enable_private_link" {
  description = "Whether to enable private link for Databricks"
  type        = bool
  default     = false
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

variable "managed_identity_id" {
  description = "The ID of the user-assigned managed identity to use for authentication"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
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
