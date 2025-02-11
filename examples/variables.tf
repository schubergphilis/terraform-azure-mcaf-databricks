variable "resource_group_name" {
  description = "The Azure resource group where resources will be created."
  type        = string
}

variable "prefix" {
  type        = string
  description = "A prefix used for naming resources."
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "vnet_name" {
  description = "The name of the Virtual Network."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network."
  type        = list(string)
}

variable "subnets" {
  description = "A map of subnet configurations."
  type = map(object({
    name              = string
    address_prefix    = string
    service_endpoints = list(string)
  }))
}

variable "keyvault_name" {
  type        = string
  description = "The name of the Azure Key Vault."
}

variable "keyvault_sku" {
  type        = string
  description = "The SKU of the Key Vault (e.g., standard, premium)."
}

variable "keyvault_access_policies" {
  type = list(object({
    tenant_id               = string
    object_id               = string
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
  }))
  description = "List of access policies for the Key Vault."
}

variable "databricks_workspace_name" {
  description = "The name of the Databricks workspace."
  type        = string
}

variable "databricks_sku" {
  description = "The SKU tier for Databricks (standard, premium)."
  type        = string
}

variable "enable_private_link" {
  description = "Whether to enable private link for Databricks."
  type        = bool
  default     = false
}

variable "tenant_id" {
  description = "The Azure tenant ID."
  type        = string
}

variable "metastore_id" {
  description = "The ID of the Databricks metastore to assign to the workspace."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "managed_identity_id" {
  description = "The ID of the user-assigned managed identity to use for authentication."
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account."
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the storage account."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault."
  type        = string
}

variable "private_subnet_nsg_id" {
  description = "The ID of the Network Security Group (NSG) associated with the private subnet."
  type        = string
}

variable "public_subnet_nsg_id" {
  description = "The ID of the Network Security Group (NSG) associated with the public subnet."
  type        = string
}

variable "private_subnet_name" {
  description = "The name of the private subnet."
  type        = string
}

variable "public_subnet_name" {
  description = "The name of the public subnet."
  type        = string
}

variable "vnet_id" {
  description = "The ID of the Virtual Network (VNet)."
  type        = string
}

variable "managed_disk_key_id" {
  description = "The ID of the CMK for managed disks."
  type        = string
}

variable "managed_services_key_id" {
  description = "The ID of the CMK for managed services."
  type        = string
}

variable "databricks_host" {
  description = "The Databricks workspace host URL."
  type        = string
  default     = ""
}