variable "workspace" {
  description = "Configuration for the Databricks workspace"
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    sku                 = string
    enable_private_link = bool
  })
}

variable "managed_identity" {
  description = "Managed identity configuration"
  type = object({
    enabled = bool
    name    = string
  })
  default = {
    enabled = false
    name    = ""
  }
}

variable "network" {
  description = "Network configuration provided by the Network module"
  type = object({
    vnet_id             = string
    private_subnet_id   = string
    public_subnet_id    = string
    nsg_id              = string
    private_endpoint_ids = list(string)
  })
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}