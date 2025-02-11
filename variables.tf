variable "prefix" {
  type        = string
  description = "A prefix used for naming resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where Databricks will be deployed."
}

variable "location" {
  type        = string
  description = "The Azure region where Databricks will be deployed."
}

variable "databricks_sku" {
  type        = string
  description = "The SKU of the Databricks workspace."
  default     = "premium"
}

variable "vnet_id" {
  type        = string
  description = "The ID of the Virtual Network where Databricks will be deployed."
}

variable "private_subnet_name" {
  type        = string
  description = "The name of the private subnet for Databricks."
}

variable "public_subnet_name" {
  type        = string
  description = "The name of the public subnet for Databricks."
}

variable "private_subnet_nsg_id" {
  type        = string
  description = "The NSG ID for the private subnet."
}

variable "public_subnet_nsg_id" {
  type        = string
  description = "The NSG ID for the public subnet."
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Azure Key Vault."
}

variable "managed_disk_key_id" {
  type        = string
  description = "The ID of the CMK for managed disks."
}

variable "managed_services_key_id" {
  type        = string
  description = "The ID of the CMK for managed services."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
  default     = {}
}

variable "metastore_id" {
  type        = string
  description = "The ID of the Databricks metastore to assign to the workspace."
  default     = ""
}

variable "enable_private_link" {
  type        = bool
  description = "Enable private link for Databricks."
  default     = true
}