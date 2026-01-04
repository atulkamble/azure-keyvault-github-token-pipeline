Below is a **clean, beginner-friendly, end-to-end project** that shows how to:

> ✅ Create a **GitHub Personal Access Token (PAT)**
> ✅ Store it securely in **Azure Key Vault**
> ✅ Use it **safely inside an Azure DevOps Pipeline**

This is exactly the kind of **real-world DevOps security flow** interviewers and production teams expect.

---

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

## 🚀 Want Next?

I can provide:

* 🔁 Token rotation automation
* 🔐 RBAC-based Key Vault setup
* 🧪 Full demo with private GitHub repo
* 📘 README + architecture diagram

Just tell me 👍
