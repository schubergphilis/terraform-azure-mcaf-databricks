#!/bin/bash
# Run this script first to be able to test the module if you don't have the existing resources.

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
KEYVAULT_NAME="test-keyvault"
MANAGED_IDENTITY_NAME="test-managed-identity"

# Resource existence function validation
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

# Create Virtual Network if not exists
if ! az network vnet show --resource-group "$RESOURCE_GROUP" --name "$VNET_NAME" &> /dev/null; then
  echo "Creating Virtual Network: $VNET_NAME"
  az network vnet create --name "$VNET_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --address-prefix "$VNET_ADDRESS_PREFIX"
else
  echo "Virtual Network $VNET_NAME already exists. Skipping..."
fi

# Create Subnets
for SUBNET_NAME in "$PRIVATE_SUBNET_NAME" "$PUBLIC_SUBNET_NAME"; do
  ADDRESS_PREFIX_VAR="${SUBNET_NAME}_PREFIX"
  if ! az network vnet subnet show --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$SUBNET_NAME" &> /dev/null; then
    echo "Creating Subnet: $SUBNET_NAME"
    az network vnet subnet create --vnet-name "$VNET_NAME" --name "$SUBNET_NAME" --resource-group "$RESOURCE_GROUP" --address-prefix "${!ADDRESS_PREFIX_VAR}"
  else
    echo "Subnet $SUBNET_NAME already exists. Skipping..."
  fi
done

# Create Network Security Groups
for NSG in "$PRIVATE_NSG" "$PUBLIC_NSG"; do
  if ! az network nsg show --resource-group "$RESOURCE_GROUP" --name "$NSG" &> /dev/null; then
    echo "Creating Network Security Group: $NSG"
    az network nsg create --resource-group "$RESOURCE_GROUP" --name "$NSG"
  else
    echo "NSG $NSG already exists. Skipping..."
  fi
done

# Associate NSGs with Subnets
az network vnet subnet update --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$PRIVATE_SUBNET_NAME" --network-security-group "$PRIVATE_NSG"
az network vnet subnet update --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$PUBLIC_SUBNET_NAME" --network-security-group "$PUBLIC_NSG"

# Create Azure Key Vault
if ! az keyvault show --name "$KEYVAULT_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
  echo "Creating Key Vault: $KEYVAULT_NAME"
  az keyvault create --name "$KEYVAULT_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --sku standard
else
  echo "Key Vault $KEYVAULT_NAME already exists. Skipping..."
fi

# Create Managed Identity
if ! az identity show --name "$MANAGED_IDENTITY_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
  echo "Creating Managed Identity: $MANAGED_IDENTITY_NAME"
  az identity create --name "$MANAGED_IDENTITY_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION"
else
  echo "Managed Identity $MANAGED_IDENTITY_NAME already exists. Skipping..."
fi

# Output important values for Terraform variables
PRIVATE_SUBNET_ID=$(az network vnet subnet show --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$PRIVATE_SUBNET_NAME" --query id --output tsv)
PUBLIC_SUBNET_ID=$(az network vnet subnet show --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$PUBLIC_SUBNET_NAME" --query id --output tsv)
NSG_PRIVATE_ID=$(az network nsg show --resource-group "$RESOURCE_GROUP" --name "$PRIVATE_NSG" --query id --output tsv)
NSG_PUBLIC_ID=$(az network nsg show --resource-group "$RESOURCE_GROUP" --name "$PUBLIC_NSG" --query id --output tsv)
MANAGED_IDENTITY_ID=$(az identity show --name "$MANAGED_IDENTITY_NAME" --resource-group "$RESOURCE_GROUP" --query id --output tsv)
KEYVAULT_ID=$(az keyvault show --name "$KEYVAULT_NAME" --resource-group "$RESOURCE_GROUP" --query id --output tsv)

# Display the necessary outputs
echo "Resource Group: $RESOURCE_GROUP"
echo "Virtual Network: $VNET_NAME"
echo "Private Subnet ID: $PRIVATE_SUBNET_ID"
echo "Public Subnet ID: $PUBLIC_SUBNET_ID"
echo "Private NSG ID: $NSG_PRIVATE_ID"
echo "Public NSG ID: $NSG_PUBLIC_ID"
echo "Managed Identity ID: $MANAGED_IDENTITY_ID"
echo "Key Vault ID: $KEYVAULT_ID"
