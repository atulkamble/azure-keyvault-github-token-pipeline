# Azure Key Vault 

Microsoft Azure Key Vault is an Azure service used to **securely store and control access to sensitive information** such as passwords, connection strings, API keys, certificates, and encryption keys.

## 1. Why Azure Key Vault?

Without Key Vault, developers may accidentally store secrets directly in:

```text
Application Code
.env files
appsettings.json
Pipeline YAML
GitHub repositories
Terraform files
Scripts
```

For example, avoid:

```python
db_password = "MyPassword@123"
```

Instead:

```text
Application
    |
    v
Azure Key Vault
    |
    +-- Database Password
    +-- API Key
    +-- Certificate
    +-- Encryption Key
```

The application retrieves the secret securely when required.

---

## 2. What Can Key Vault Store?

There are three major object types:

| Object           | Purpose              | Example                              |
| ---------------- | -------------------- | ------------------------------------ |
| **Secrets**      | Sensitive text/value | Password, API key, connection string |
| **Keys**         | Cryptographic keys   | RSA key used for encryption/signing  |
| **Certificates** | TLS/SSL certificates | HTTPS certificate                    |

### Secret

```text
Name: database-password
Value: P@ssw0rd123
```

### Key

Used for cryptographic operations such as:

```text
Encryption
Decryption
Signing
Verification
```

### Certificate

Commonly used for:

```text
HTTPS / TLS
Application authentication
Certificate lifecycle management
```

---

## 3. Key Vault Architecture

```text
             Azure Key Vault
                    |
        +-----------+-----------+
        |           |           |
     Secrets       Keys    Certificates
        |
        v
  database-password
        ^
        |
   Managed Identity
        |
        |
   Azure Application
```

The important idea is:

**Application doesn't need the password hard-coded in its source code.**

---

## 4. Authentication vs Authorization

These are different concepts.

**Authentication:** Who are you?

Microsoft Entra ID handles authentication.

**Authorization:** What are you allowed to do?

For example:

```text
User A
  |
  +-- Can read secrets
  +-- Cannot delete secrets
```

Azure RBAC can control these permissions.

---

## 5. Key Vault Access Models

Azure Key Vault supports two permission models:

### Azure RBAC

Modern and generally recommended approach.

Examples of built-in roles include:

```text
Key Vault Administrator
Key Vault Secrets Officer
Key Vault Secrets User
Key Vault Crypto Officer
Key Vault Certificates Officer
```

For example:

```text
Developer
   |
Key Vault Secrets User
   |
   v
Read Secret
```

### Vault Access Policy

The older access-control model where permissions are configured directly for:

```text
Keys
Secrets
Certificates
```

For new deployments, Azure RBAC is generally the preferred model. Microsoft documents both approaches in its current Key Vault guidance. [Azure Key Vault access overview](https://learn.microsoft.com/azure/key-vault/general/security-features?utm_source=chatgpt.com)

---

# Basic Lab — Create and Use Azure Key Vault

## Step 1 — Create a Resource Group

Using Azure CLI:

```bash
az group create --name keyvault-rg --location eastus
```

Check:

```bash
az group list -o table
```

---

## Step 2 — Create Key Vault

Key Vault names must be globally unique.

```bash
az keyvault create --name atul-kv-12345 --resource-group keyvault-rg --location eastus --enable-rbac-authorization true
```

Check:

```bash
az keyvault list -o table
```

You can replace `atul-kv-12345` with your own unique name.

---

## Step 3 — Create a Secret

Let's store a database password:

```bash
az keyvault secret set --vault-name atul-kv-12345 --name database-password --value "MySecurePassword@123"

```

Now the secret exists inside Key Vault.

```text
Key Vault
   |
   +-- database-password
           |
           +-- MySecurePassword@123
```

## Role Assignment 
```
az role assignment create --role "Key Vault Secrets Officer" --assignee 569e301d-629a-4d19-a477-a250605ef6ba --scope /subscriptions/08b7b8d4-af42-4972-9517-11ea256ea068/resourceGroups/keyvault-rg/providers/Microsoft.KeyVault/vaults/atul-kv-12345
```
```
az role assignment list --assignee 569e301d-629a-4d19-a477-a250605ef6ba --scope /subscriptions/08b7b8d4-af42-4972-9517-11ea256ea068/resourceGroups/keyvault-rg/providers/Microsoft.KeyVault/vaults/atul-kv-12345 \
  -o table
```
```
az keyvault secret set --vault-name atul-kv-12345 --name database-password --value "MySecurePassword@123"
```
---

## Step 4 — List Secrets

```bash
az keyvault secret list --vault-name atul-kv-12345 -o table
```

Notice that listing secrets doesn't simply print all secret values.

---

## Step 5 — Retrieve the Secret

```bash
az keyvault secret show --vault-name atul-kv-12345 --name database-password
```

To return only the value:

```bash
az keyvault secret show --vault-name atul-kv-12345 --name database-password --query value -o tsv
```

Expected:

```text
MySecurePassword@123
```

---

# Practice 2 — Store Multiple Secrets

Create username:

```bash
az keyvault secret set \
  --vault-name atul-kv-12345 \
  --name database-username \
  --value "adminuser"
```

Create API key:

```bash
az keyvault secret set \
  --vault-name atul-kv-12345 \
  --name api-key \
  --value "abc123xyz"
```

List them:

```bash
az keyvault secret list \
  --vault-name atul-kv-12345 \
  -o table
```

Your vault now conceptually contains:

```text
atul-kv-12345
│
├── database-username
├── database-password
└── api-key
```

---

# Practice 3 — Secret Versioning

Update the database password:

```bash
az keyvault secret set \
  --vault-name atul-kv-12345 \
  --name database-password \
  --value "NewPassword@456"
```

Key Vault creates a **new version** rather than simply treating it as an unrelated secret.

View versions:

```bash
az keyvault secret list-versions \
  --vault-name atul-kv-12345 \
  --name database-password \
  -o table
```

Conceptually:

```text
database-password
       |
       +-- Version 1 → MySecurePassword@123
       |
       +-- Version 2 → NewPassword@456
```

---

# Practice 4 — Delete a Secret

```bash
az keyvault secret delete \
  --vault-name atul-kv-12345 \
  --name api-key
```

Check deleted secrets:

```bash
az keyvault secret list-deleted \
  --vault-name atul-kv-12345 \
  -o table
```

Recover it:

```bash
az keyvault secret recover \
  --vault-name atul-kv-12345 \
  --name api-key
```

This is useful for demonstrating **soft delete and recovery**.

---

# Practice 5 — Azure Portal

For classroom practice, also perform the same lab through the Azure Portal:

```text
Azure Portal
     ↓
Create a resource
     ↓
Key Vault
     ↓
Create
     ↓
Select Subscription
     ↓
Resource Group
     ↓
Enter Key Vault Name
     ↓
Select Region
     ↓
Permission model: Azure RBAC
     ↓
Review + Create
```

After deployment:

```text
Key Vault
   ↓
Objects
   ↓
Secrets
   ↓
Generate/Import
   ↓
Name: database-password
   ↓
Secret value: MySecurePassword@123
   ↓
Create
```

---

# Practice 6 — RBAC

This is an important real-world lab.

Suppose an application needs to **read secrets but shouldn't administer the vault**.

Assign an appropriate role such as:

```text
Key Vault Secrets User
```

Architecture:

```text
Azure Application
       |
       | Managed Identity
       v
Microsoft Entra ID
       |
       | RBAC
       v
Azure Key Vault
       |
       v
database-password
```

This leads to an important Azure security principle:

> **Don't give an application more permissions than it actually needs.**

---

## Key Vault + Managed Identity

A very important production pattern is:

```text
Azure VM / App Service / Function
              |
              | Managed Identity
              v
       Microsoft Entra ID
              |
              v
        Azure Key Vault
              |
              v
           Secret
```

You avoid putting Azure credentials directly inside application code.

For example:

**Bad:**

```python
username = "admin"
password = "Password@123"
```

**Better architecture:**

```python
password = get_secret_from_key_vault()
```

The application authenticates using its identity and retrieves only the secrets it is authorized to access.

[Microsoft tutorial: use Key Vault with managed identities](https://learn.microsoft.com/azure/key-vault/general/authentication?utm_source=chatgpt.com)

---

# Important Interview / Exam Points

| Topic                    | Remember                                                           |
| ------------------------ | ------------------------------------------------------------------ |
| Key Vault                | Secure store for sensitive information                             |
| Secret                   | Password/API key/connection string                                 |
| Key                      | Cryptographic key                                                  |
| Certificate              | TLS/SSL and authentication certificates                            |
| Authentication           | Microsoft Entra ID                                                 |
| Authorization            | Azure RBAC or access policies                                      |
| Recommended access model | Azure RBAC for new implementations                                 |
| Managed Identity         | Allows Azure resources to authenticate without storing credentials |
| Secret Versioning        | New secret values can create new versions                          |
| Soft Delete              | Helps recover deleted Key Vault objects                            |
| Least Privilege          | Give only required permissions                                     |
| Hardcoding               | Avoid passwords/secrets in application code                        |
| Production networking    | Consider firewall rules/private endpoints                          |

## Recommended Learning Flow

For teaching Azure Key Vault from basic to practical:

```text
1. What is Key Vault?
        ↓
2. Why do we need it?
        ↓
3. Secrets vs Keys vs Certificates
        ↓
4. Create Key Vault
        ↓
5. Create/Retrieve Secret
        ↓
6. Secret Versioning
        ↓
7. Delete + Recover
        ↓
8. Azure RBAC
        ↓
9. Managed Identity
        ↓
10. VM/App Service → Key Vault
        ↓
11. Private Endpoint
        ↓
12. Key Vault with Azure DevOps
```

For the **next hands-on lab**, the most useful progression would be **Azure VM → Managed Identity → Key Vault → retrieve a secret without storing Azure credentials on the VM**.



# 🔐 Project: GitHub Token → Azure Key Vault → Azure Pipeline

---

## 📌 Architecture Flow (Simple)

```
GitHub PAT
   ↓
Azure Key Vault (Secret)
   ↓
Azure DevOps Service Connection
   ↓
Azure Pipeline (uses token securely)
```

---

## 🧩 Prerequisites

* GitHub account
* Azure account
* Azure DevOps organization & project
* Azure CLI installed
* Basic YAML knowledge

---

## STEP 1️⃣ Create GitHub Personal Access Token (PAT)

### 🔹 GitHub UI Steps

1. GitHub → **Profile → Settings**

2. **Developer settings**

3. **Personal access tokens → Tokens (classic)**

4. Click **Generate new token**

5. Set:

   * **Note**: `azure-pipeline-token`
   * **Expiration**: 30–90 days
   * **Scopes**:

     ```
     ✔ repo
     ✔ workflow
     ```

6. **Generate token**

7. 🔴 **COPY the token immediately** (won’t be shown again)

Example:

```
ghp_xxxxxxxxxxxxxxxxxxxxx
```

---

## STEP 2️⃣ Create Azure Key Vault

### 🔹 Login to Azure

```bash
az login
```

### 🔹 Create Resource Group

```bash
az group create \
  --name rg-kv-demo \
  --location eastus
```

### 🔹 Create Key Vault

```bash
az keyvault create \
  --name kv-github-demo \
  --resource-group rg-kv-demo \
  --location eastus
```

---

## STEP 3️⃣ Store GitHub Token in Azure Key Vault

```bash
az keyvault secret set \
  --vault-name kv-github-demo \
  --name github-token \
  --value ghp_xxxxxxxxxxxxxxxxxxxxx
```

✅ Token is now **encrypted and secure**

---

## STEP 4️⃣ Create Azure DevOps Service Connection

This allows Azure Pipeline to read secrets from Key Vault.

### 🔹 Azure DevOps UI

1. **Project Settings**
2. **Service connections**
3. **New service connection**
4. Choose **Azure Resource Manager**
5. Select:

   * **Authentication**: Automatic
   * **Subscription**
   * **Resource Group**: `rg-kv-demo`
6. Name it:

   ```
   azure-kv-connection
   ```

---

## STEP 5️⃣ Grant Key Vault Access to Azure DevOps

### 🔹 Enable Access Policy (RBAC-based vaults also supported)

```bash
az keyvault set-policy \
  --name kv-github-demo \
  --spn <SERVICE-PRINCIPAL-ID> \
  --secret-permissions get list
```

📌 Service Principal ID comes from the service connection.

---

## STEP 6️⃣ Azure Pipeline YAML (Basic & Secure)

### 📄 `azure-pipelines.yml`

```yaml
trigger:
- main

variables:
- group: kv-secrets

stages:
- stage: FetchToken
  jobs:
  - job: UseGitHubToken
    pool:
      vmImage: ubuntu-latest

    steps:
    - task: AzureKeyVault@2
      inputs:
        azureSubscription: 'azure-kv-connection'
        KeyVaultName: 'kv-github-demo'
        SecretsFilter: 'github-token'
        RunAsPreJob: true

    - script: |
        echo "Token fetched successfully"
        echo "GitHub Token Length: ${#GITHUB_TOKEN}"
      env:
        GITHUB_TOKEN: $(github-token)
```

🔐 **Token value is masked automatically**
You’ll see:

```
***
```

in logs instead of the real token.

---

## STEP 7️⃣ (Optional) Use Token for GitHub Operations

### Example: Clone Private Repo

```yaml
- script: |
    git clone https://$GITHUB_TOKEN@github.com/atuljkamble/private-repo.git
  env:
    GITHUB_TOKEN: $(github-token)
```

---

## 🔒 Security Best Practices

✅ Never hard-code tokens
✅ Always use **Key Vault**
✅ Rotate GitHub tokens regularly
✅ Use **least privilege scopes**
✅ Mask secrets in pipeline logs

---

## 📂 Suggested GitHub Repo Name

```
azure-keyvault-github-token-pipeline
```

---

## 🧠 Interview Talking Points

* Why Key Vault instead of pipeline variables?
* How secrets are injected securely at runtime
* Difference between PAT and OAuth
* Token rotation strategy
* RBAC vs Access Policies

---
