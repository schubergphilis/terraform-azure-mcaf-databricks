#!/bin/bash

# Run az login first and choose your subscription

# Example Variables
RESOURCE_GROUP="test-rg"
LOCATION="West Europe"
VNET_NAME="test-vnet"
VNET_ADDRESS_PREFIX="10.2.0.0/16"
PRIVATE_SUBNET_NAME="test-private-subnet"
PRIVATE_SUBNET_PREFIX="10.2.1.0/24"
PUBLIC_SUBNET_NAME="test-public-subnet"
PUBLIC_SUBNET_PREFIX="10.2.2.0/24"
PRIVATE_NSG="private-subnet-nsg"
PUBLIC_NSG="public-subnet-nsg"
KEYVAULT_NAME="anytrex-kv3"
STORAGE_ACCOUNT_NAME="anytrexsa3"
MANAGED_IDENTITY_NAME="test-managed-identity"
TFVARS_FILE="terraform.tfvars"

# Get Subscription ID and Tenant ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
TENANT_ID=$(az account show --query tenantId --output tsv)

# Function to validate if a resource exists
validate_resource_group() {
  if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo "Resource Group $RESOURCE_GROUP exists. Proceeding..."
  else
    echo "Resource Group $RESOURCE_GROUP does not exist. Creating..."
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
  fi
}

# Run validation
validate_resource_group

# Create Managed Identity
if ! az identity show --name "$MANAGED_IDENTITY_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
  echo "Creating Managed Identity: $MANAGED_IDENTITY_NAME"
  az identity create --name "$MANAGED_IDENTITY_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION"
fi
MANAGED_IDENTITY_ID=$(az identity show --name "$MANAGED_IDENTITY_NAME" --resource-group "$RESOURCE_GROUP" --query id --output tsv)
MANAGED_IDENTITY_OBJECT_ID=$(az identity show --name "$MANAGED_IDENTITY_NAME" --resource-group "$RESOURCE_GROUP" --query principalId --output tsv)

# Assign Managed Identity Contributor Role to the Subscription
az role assignment create \
  --assignee-object-id "$MANAGED_IDENTITY_OBJECT_ID" \
  --assignee-principal-type "ServicePrincipal" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Create Virtual Network
az network vnet create --name "$VNET_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --address-prefix "$VNET_ADDRESS_PREFIX"

# Create Subnets
az network vnet subnet create --vnet-name "$VNET_NAME" --name "$PRIVATE_SUBNET_NAME" --resource-group "$RESOURCE_GROUP" --address-prefix "$PRIVATE_SUBNET_PREFIX"
az network vnet subnet create --vnet-name "$VNET_NAME" --name "$PUBLIC_SUBNET_NAME" --resource-group "$RESOURCE_GROUP" --address-prefix "$PUBLIC_SUBNET_PREFIX"

# Create Network Security Groups
az network nsg create --resource-group "$RESOURCE_GROUP" --name "$PRIVATE_NSG"
az network nsg create --resource-group "$RESOURCE_GROUP" --name "$PUBLIC_NSG"

# Associate NSGs with Subnets
az network vnet subnet update --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$PRIVATE_SUBNET_NAME" --network-security-group "$PRIVATE_NSG"
az network vnet subnet update --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$PUBLIC_SUBNET_NAME" --network-security-group "$PUBLIC_NSG"

# Create Azure Key Vault
az keyvault create --name "$KEYVAULT_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --sku standard

# Create Storage Account
az storage account create --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --sku Standard_LRS

# Retrieve required outputs
PRIVATE_SUBNET_ID=$(az network vnet subnet show --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$PRIVATE_SUBNET_NAME" --query id --output tsv)
PUBLIC_SUBNET_ID=$(az network vnet subnet show --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$PUBLIC_SUBNET_NAME" --query id --output tsv)
NSG_PRIVATE_ID=$(az network nsg show --resource-group "$RESOURCE_GROUP" --name "$PRIVATE_NSG" --query id --output tsv)
NSG_PUBLIC_ID=$(az network nsg show --resource-group "$RESOURCE_GROUP" --name "$PUBLIC_NSG" --query id --output tsv)
KEYVAULT_ID=$(az keyvault show --name "$KEYVAULT_NAME" --resource-group "$RESOURCE_GROUP" --query id --output tsv)
STORAGE_ACCOUNT_ID=$(az storage account show --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" --query id --output tsv)

# Update terraform.tfvars
update_tfvars() {
    VAR_NAME=$1
    VAR_VALUE=$2

    ESCAPED_VALUE=$(echo "$VAR_VALUE" | sed 's/\//\\\//g')
    if grep -q "^$VAR_NAME" "$TFVARS_FILE"; then
        sed -i.bak "s|^$VAR_NAME = .*|$VAR_NAME = \"$ESCAPED_VALUE\"|" "$TFVARS_FILE"
    else
        echo "$VAR_NAME = \"$ESCAPED_VALUE\"" >> "$TFVARS_FILE"
    fi
}

update_tfvars "subscription_id" "$SUBSCRIPTION_ID"
update_tfvars "tenant_id" "$TENANT_ID"
update_tfvars "managed_identity_id" "$MANAGED_IDENTITY_ID"
update_tfvars "key_vault_id" "$KEYVAULT_ID"
update_tfvars "storage_account_id" "$STORAGE_ACCOUNT_ID"
update_tfvars "private_subnet_nsg_id" "$NSG_PRIVATE_ID"
update_tfvars "public_subnet_nsg_id" "$NSG_PUBLIC_ID"

# Update Key Vault Access Policies
update_tfvars "keyvault_access_policies" "[
  {
    tenant_id               = \"$TENANT_ID\"
    object_id               = \"$MANAGED_IDENTITY_OBJECT_ID\"
    key_permissions         = [\"Get\", \"UnwrapKey\", \"WrapKey\"]
    secret_permissions      = [\"Get\", \"List\"]
    certificate_permissions = [\"Get\", \"List\"]
  }
]"

echo "✅ terraform.tfvars has been updated with the necessary values without overwriting other configurations."
