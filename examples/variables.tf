variable "resource_group_name" {
  description = "The Azure resource group where resources will be created"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "prefix" {
  description = "A prefix used for naming resources."
  type        = string
}

# Networking
variable "vnet_name" {
  description = "The name of the Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network"
  type        = list(string)
}

variable "subnets" {
  description = "Subnet configuration"
  type = map(object({
    name                          = string
    address_prefixes              = list(string)
    create_network_security_group = optional(bool, false)
  }))
}

variable "custom_nsg_rules" {
  description = "Custom security rules for the NSGs (optional)."
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_address_prefix      = optional(string)
    source_port_range          = optional(string)
    destination_address_prefix = optional(string)
    destination_port_range     = optional(string)
  }))
  default = []
}

# Storage Account
variable "storage_account_name" {
  description = "The name of the Storage Account."
  type        = string
}

# Key Vault
variable "keyvault_name" {
  type        = string
  description = "The name of the Azure Key Vault."
}

variable "keyvault_sku" {
  type        = string
  description = "The SKU of the Key Vault (e.g., standard, premium)."
}

variable "cmk_key_vault_id" {
  description = "Key Vault ID for Customer Managed Key encryption"
  type        = string
  default     = null
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

# Databricks
variable "databricks_workspace_name" {
  description = "The name of the Databricks workspace"
  type        = string
}

variable "databricks_sku" {
  description = "The SKU tier for Databricks (standard, premium)"
  type        = string
}

variable "metastore_id" {
  description = "The ID of the Databricks metastore to assign to the workspace"
  type        = string
  default     = ""
}

# Azure Subscription & Identity
variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}

variable "managed_identity_id" {
  description = "The ID of the user-assigned managed identity to use for authentication"
  type        = string
}

# Tags
variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "databricks_host" {
  description = "The Databricks workspace host URL."
  type        = string
  default     = "" # Default to empty to avoid breaking execution
}

# IAM
variable "databricks_mid_name" {
  description = "The name of the Databricks Managed Identity."
  type        = string
  default     = "databricks-mid"
}

variable "databricks_mid_resource_group" {
  description = "The resource group where Databricks Managed Identity is created."
  type        = string
}