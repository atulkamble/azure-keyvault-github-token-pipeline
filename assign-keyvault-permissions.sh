#!/bin/bash

# Service Principal Object ID from the error
ASSIGNEE="45ec9bd4-7276-46bf-93b0-1cd04ac02144"

# Key Vault details
SUBSCRIPTION="08b7b8d4-af42-4972-9517-11ea256ea068"
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
