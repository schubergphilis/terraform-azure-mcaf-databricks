variable "prefix" {
  type        = string
  description = "A prefix used for naming resources."
}

variable "resource_group_name" {
  description = "The Azure resource group where resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "databricks_workspace_name" {
  description = "The name of the Databricks workspace."
  type        = string
}

variable "databricks_sku" {
  description = "The SKU tier for Databricks (standard, premium)."
  type        = string
}

variable "vnet_id" {
  description = "The ID of the Virtual Network where Databricks will be deployed."
  type        = string
}

variable "private_subnet_name" {
  description = "The name of the private subnet for Databricks."
  type        = string
}

variable "public_subnet_name" {
  description = "The name of the public subnet for Databricks."
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

variable "private_subnet_id" {
  description = "The ID of the private subnet for Databricks."
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet for Databricks."
  type        = string
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

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault."
  type        = string
}

variable "managed_disk_key_id" {
  description = "The Key Vault key ID used to encrypt Databricks-managed disks."
  type        = string
}

variable "managed_services_key_id" {
  description = "The Key Vault key ID used to encrypt Databricks-managed services."
  type        = string
}

variable "managed_identity_id" {
  description = "The ID of the user-assigned managed identity for Databricks (if applicable)."
  type        = string
  default     = ""
}

variable "tenant_id" {
  description = "The Azure tenant ID."
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID."
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

variable "databricks_host" {
  description = "The Databricks workspace host URL."
  type        = string
  default     = "" # Default to empty to avoid breaking execution
}