module "network" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-network.git?ref=main"

  vnet = {
    name                = var.vnet_name
    resource_group_name = var.resource_group_name
    location            = var.location
    address_space       = var.vnet_address_space
  }

  subnets = var.subnets
  tags    = var.tags
}

module "keyvault" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-core?ref=main"

  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "standard"
  tenant_id           = var.tenant_id
  access_policies     = var.keyvault_access_policies
  tags                = var.tags
}

module "databricks" {
  source = "git::https://github.com/schubergphilis/terraform-azure-mcaf-databricks?ref=develop"

  workspace = {
    name                = var.databricks_workspace_name
    resource_group_name = var.resource_group_name
    location            = var.location
    sku                 = var.databricks_sku
    enable_private_link = var.enable_private_link
  }

  network = {
    vnet_id             = module.network.id
    private_subnet_name = module.network.subnets["private_subnet"].name
    public_subnet_name  = module.network.subnets["public_subnet"].name
    private_subnet_nsg_id = module.network.all_network_security_groups["private_subnet"].id
    public_subnet_nsg_id  = module.network.all_network_security_groups["public_subnet"].id
  }

  managed_disk_key_id     = module.keyvault.keys["managed-disk"].id
  managed_services_key_id = module.keyvault.keys["managed-services"].id
  key_vault_id            = module.keyvault.id
  tenant_id               = var.tenant_id
  databricks_app_object_id = var.databricks_app_object_id
  metastore_id            = var.metastore_id
  tags                    = var.tags
}