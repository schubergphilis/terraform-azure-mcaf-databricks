# Create Network Security Groups (NSGs) for private and public subnets
resource "azurerm_network_security_group" "private" {
  name                = "${var.prefix}-private-subnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    {
      "Resource Type" = "Network Security Group"
    },
    var.tags
  )
}

resource "azurerm_user_assigned_identity" "databricks_mid" {
  name                = var.databricks_mid_name
  resource_group_name = var.databricks_mid_resource_group
  location            = var.location
}

resource "azurerm_role_assignment" "databricks_mid_kv" {
  scope                = module.keyvault.key_vault_id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.databricks_mid.principal_id
}

resource "azurerm_key_vault_access_policy" "databricks_mid" {
  key_vault_id = module.keyvault.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.databricks_mid.principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "azurerm_network_security_group" "public" {
  name                = "${var.prefix}-public-subnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    {
      "Resource Type" = "Network Security Group"
    },
    var.tags
  )
}

# Associate NSGs with subnets
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = var.private_subnet_id
  network_security_group_id = azurerm_network_security_group.private.id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = var.public_subnet_id
  network_security_group_id = azurerm_network_security_group.public.id
}

# Databricks Workspace
resource "azurerm_databricks_workspace" "this" {
  name                                  = "${var.prefix}-adb-workspace"
  resource_group_name                   = var.resource_group_name
  location                              = var.location
  sku                                   = var.databricks_sku
  managed_disk_cmk_key_vault_key_id     = var.managed_disk_key_id
  managed_services_cmk_key_vault_key_id = var.managed_services_key_id
  customer_managed_key_enabled          = true
  infrastructure_encryption_enabled     = true
  public_network_access_enabled         = false
  network_security_group_rules_required = "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = var.vnet_id
    public_subnet_name                                   = var.public_subnet_name
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_network_security_group_association_id  = azurerm_network_security_group.public.id
    private_subnet_network_security_group_association_id = azurerm_network_security_group.private.id
  }

  tags = merge(
    {
      "Resource Type" = "Databricks Workspace"
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

output "private_subnet_nsg_id" {
  value       = azurerm_network_security_group.private.id
  description = "The ID of the Network Security Group (NSG) associated with the private subnet."
}

output "public_subnet_nsg_id" {
  value       = azurerm_network_security_group.public.id
  description = "The ID of the Network Security Group (NSG) associated with the public subnet."
}