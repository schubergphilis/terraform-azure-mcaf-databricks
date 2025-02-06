resource_group_name = "test-rg"
location = "West Europe"

vnet_name = "test-vnet"
vnet_address_space = ["10.2.0.0/16"]

subnets = {
  private_subnet = {
    name           = "test-private-subnet"
    address_prefix = "10.2.1.0/24"
    service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
  }
  public_subnet = {
    name           = "test-public-subnet"
    address_prefix = "10.2.2.0/24"
    service_endpoints = []
  }
}

databricks_workspace_name = "test-databricks-ws"
databricks_sku = "premium"
enable_private_link = true

managed_identity = {
  enabled = true
  name    = "test-managed-identity"
}