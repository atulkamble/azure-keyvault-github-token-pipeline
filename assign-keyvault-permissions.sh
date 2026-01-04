#!/bin/bash

# Service Principal Object ID from the error
ASSIGNEE="fd46ad98-4001-4a32-8e0d-a919420b0c98"

# Key Vault details
SUBSCRIPTION="50818730-e898-4bc4-bc35-d998af53d719"
RESOURCE_GROUP="rg-kv-demo"
KEY_VAULT_NAME="kv-github-demo"

# Grant Key Vault Secrets User role (read-only access to secrets)
echo "Assigning Key Vault Secrets User role..."
az role assignment create \
  --assignee $ASSIGNEE \
  --role "Key Vault Secrets User" \
  --scope /subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME

echo ""
echo "✓ Role assignment completed!"
echo "Note: Permission propagation may take 1-2 minutes."
