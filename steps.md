# 🔐 Azure Key Vault + GitHub Token + Azure DevOps Pipeline

## 📌 Objective

Securely store a GitHub Personal Access Token (PAT) in **Azure Key Vault** and use it in an **Azure DevOps Pipeline**.

---

## 🧱 Architecture Overview

* GitHub Repo → Azure DevOps Pipeline
* Azure DevOps → Service Connection
* Azure Key Vault → Stores Secret (GitHub Token)
* RBAC → Controls Access

---

## 🚀 Step-by-Step Implementation

---

## 🔹 Step 1: Create GitHub Token

In GitHub:

1. Go to:

   ```
   Settings → Developer Settings → Personal Access Tokens
   ```
2. Click **Generate Token**
3. Select required scopes (repo, workflow, etc.)
4. Copy & Save token securely

---

## 🔹 Step 2: Fork Repository

Use your demo repo:

👉 [https://github.com/atulkamble/azure-keyvault-github-token-pipeline](https://github.com/atulkamble/azure-keyvault-github-token-pipeline)

1. Click **Fork**
2. Clone to your account

---

## 🔹 Step 3: Create Azure DevOps Pipeline

In Azure DevOps:

1. Go to **Pipelines**
2. Create Pipeline
3. Select **GitHub Repo**
4. Choose:

   ```
   azure-keyvault-github-token-pipeline
   ```

---

## 🔹 Step 4: Create Azure Resources

### Login & Create Resource Group

```bash
az login

az group create \
  --name rg-kv-demo \
  --location eastus
```

### Create Key Vault

```bash
az keyvault create \
  --name kv-github-demo \
  --resource-group rg-kv-demo \
  --location eastus
```

---

## 🔹 Step 5: Store GitHub Token in Key Vault

```bash
az keyvault secret set \
  --vault-name kv-github-demo \
  --name github-token \
  --value <YOUR_GITHUB_TOKEN>
```

---

## 🔹 Step 6: Configure RBAC Roles

### Assign Roles

#### ✅ Secret Creator (User)

```bash
az role assignment create \
  --assignee-object-id 569e301d-629a-4d19-a477-a250605ef6ba \
  --assignee-principal-type User \
  --role "Key Vault Secrets Officer" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/rg-kv-demo/providers/Microsoft.KeyVault/vaults/kv-github-demo
```

#### ✅ Pipeline Access (Service Principal)

```bash
az role assignment create \
  --assignee 45ec9bd4-7276-46bf-93b0-1cd04ac02144 \
  --role "Key Vault Secrets User" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/rg-kv-demo/providers/Microsoft.KeyVault/vaults/kv-github-demo
```

---

## 🔹 Step 7: Create Service Connection

In Azure DevOps:

1. Go to:

   ```
   Project Settings → Service Connections
   ```
2. Click **New Service Connection**
3. Select:

   ```
   Azure Resource Manager
   ```
4. Choose:

   * Scope: Resource Group
   * RG: `rg-kv-demo`
   * Name: `azure-kv-connection`

⚠️ Note Service Principal ID (Example):

```
bff365bd-658f-43e6-bfb1-e6a784739ac2
```

---

## 🔹 Step 8: Grant Key Vault Access to Service Principal

### Option 1: RBAC (Recommended)

```bash
az role assignment create \
  --assignee <SP_OBJECT_ID> \
  --role "Key Vault Secrets User" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/rg-kv-demo/providers/Microsoft.KeyVault/vaults/kv-github-demo
```

### Option 2: Access Policy (Legacy)

```bash
az keyvault set-policy \
  --name kv-github-demo \
  --spn <SERVICE_PRINCIPAL_ID> \
  --secret-permissions get list
```

---

## 🔹 Step 9: Verify Secret

```bash
az keyvault secret show \
  --vault-name kv-github-demo \
  --name github-token \
  --query "id"
```

---

## 🔹 Step 10: Link Key Vault in Pipeline Library

1. Go to:

   ```
   Pipelines → Library
   ```
2. Create Variable Group: `kv-secrets`
3. Enable:

   ```
   Link secrets from Azure Key Vault
   ```
4. Select:

   * Service Connection: `azure-kv-connection`
   * Key Vault: `kv-github-demo`
5. Authorize

---

## 🔹 Step 11: Update Pipeline YAML

Ensure `azure-pipelines.yml` includes:

```yaml
variables:
- group: kv-secrets

steps:
- task: AzureKeyVault@2
  inputs:
    azureSubscription: 'azure-kv-connection'
    KeyVaultName: 'kv-github-demo'
    SecretsFilter: 'github-token'
```

---

## 🔹 Step 12: Run Pipeline

1. Go to **Pipelines**
2. Click **Run**
3. Verify logs:

   ```
   Downloading secret: github-token
   ```

---

## 🔹 Step 13: (Optional) Script Execution

```bash
chmod +x ./assign-keyvault-permissions.sh
./assign-keyvault-permissions.sh
```

---

# ⚠️ Important Troubleshooting

## ❌ Error: Not Authorized

```
Caller is not authorized to perform action
```

### ✅ Fix:

* Assign role:

  * **Key Vault Secrets User** (for pipeline)
* Wait 2–5 minutes for RBAC propagation

---

## ❌ Secret Not Found

* Check secret name: `github-token`
* Verify Key Vault linkage in Library

---

## ❌ Service Connection Issues

* Re-authorize service connection
* Validate subscription & SPN permissions

---

# 🔐 Best Practices

* Never hardcode tokens in YAML
* Use **Key Vault + Variable Groups**
* Prefer **RBAC over Access Policies**
* Rotate GitHub tokens periodically

---

# 📊 Final Flow

```
GitHub Token → Azure Key Vault → Azure DevOps Library → Pipeline → Secure Usage
```

---
