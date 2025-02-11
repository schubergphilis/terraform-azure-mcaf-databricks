resource_group_name = "test-rg"
location            = "West Europe"

vnet_name          = "test-vnet"
vnet_address_space = ["10.2.0.0/16"]

subnets = {
  private_subnet = {
    name              = "test-private-subnet"
    address_prefix    = "10.2.1.0/24"
    service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
  }
  public_subnet = {
    name              = "test-public-subnet"
    address_prefix    = "10.2.2.0/24"
    service_endpoints = []
  }
}

keyvault_name = "test-keyvault"
keyvault_access_policies = [
  {
    tenant_id           = "00000000-0000-0000-0000-000000000000"
    object_id           = "11111111-1111-1111-1111-111111111111"
    key_permissions     = ["Get", "UnwrapKey", "WrapKey"]
    secret_permissions  = ["Get", "List"]
    certificate_permissions = ["Get", "List"]
  }
]

databricks_workspace_name = "test-databricks-ws"
databricks_sku            = "premium"
enable_private_link       = true

tenant_id                 = "00000000-0000-0000-0000-000000000000"
databricks_app_object_id  = "22222222-2222-2222-2222-222222222222"
metastore_id              = "33333333-3333-3333-3333-333333333333"
managed_identity_id       = "/subscriptions/your-subscription-id/resourceGroups/your-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/your-identity"
subscription_id           = "your-subscription-id"
databricks_host           = "https://your-databricks-instance"
databricks_token          = "your-databricks-token"

tags = {
  environment = "test"
  project     = "databricks"
}