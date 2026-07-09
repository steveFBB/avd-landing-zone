# AVD Bicep

Infrastructure-as-code for deploying Azure Virtual Desktop environments.

Deploys 5 resource groups, 4 VNets with subnets and peerings, and an FSLogix storage account.

## Structure

- `main.bicep` - subscription-scoped entry point
- `parameters.example.bicepparam` - example parameters; copy and edit per customer
- `modules/` - per-resource modules

## Status

**Chunk 1 complete:** foundation networking (4 VNets, subnets, peerings) and FSLogix storage account.

### Roadmap

- Chunk 2 - Log Analytics workspace and base diagnostic settings
- Chunk 3 - NSGs and route tables
- Chunk 4 - Private endpoint, private DNS, and storage RBAC
- Chunk 5 - AVD control plane (host pool, workspace, application groups)
- Chunk 6 - Session hosts
- Chunk 7 - Bastion
- Chunk 8 - Backup and alerts

## Prerequisites

- Azure CLI installed (`az --version` to check)
- Bicep CLI installed (`az bicep version` to check; `az bicep install` if missing)
- Contributor or Owner role at the target subscription scope

## Getting started

### Clone the repo locally

Open the terminal in Studio Code (**Terminal → New Terminal**) and run:

```
mkdir C:\Projects
cd C:\Projects
git clone https://github.com/steveFBB/avd-bicep
cd avd-bicep
```

If `C:\Projects` already exists, you'll get an error on the first line - ignore it and continue.

### Open the cloned repo in Studio Code

**File → Open Folder →** select `C:\Projects\avd-bicep`.

### Recommended extensions

- **Bicep** (publisher: Microsoft) - syntax highlighting and inline validation for `.bicep` files
- **Azure CLI Tools** (optional) - helpful for running `az` commands

## Running the deployment

Placeholders like `<region>` and `<customer>` need to be replaced with real values each time. You can't just copy and paste.

### 1. Create a customer-specific parameters file

Copy the example and edit for the target environment. Real customer files are gitignored (only `parameters.example.bicepparam` gets committed):

```
copy parameters.example.bicepparam parameters.<customer>.bicepparam
```

Open the new file and set at minimum:

- `location` - Azure region (e.g. `westus`, `uksouth`)
- `storageAccountName` - globally unique, lowercase letters and digits, 3–24 chars
- All resource group names, VNet names, and IP ranges appropriate to the customer

### 2. Log in to Azure

```
az login
az account set --subscription "<subscription-name-or-id>"
az account show
```

The last command confirms which subscription is active. Check the name matches what you expect before continuing.

### 3. Dry-run with what-if

Always run this before deploying. It shows exactly what would change without making any changes:

```
az deployment sub what-if --location <region> --template-file main.bicep --parameters parameters.<customer>.bicepparam
```

If you see resources marked as **modify** or **delete**, stop and read carefully - you may be about to change something that already exists in the subscription.

### 4. Deploy

```
az deployment sub create --location <region> --name "avd-foundation" --template-file main.bicep --parameters parameters.<customer>.bicepparam
```

Deployment takes 3–5 minutes.

### 5. Validate

Check in the Azure Portal:

- All five resource groups exist
- Each VNet shows its peerings as `Connected` on both sides
- FSLogix storage account has the `profiles` file share

## Teardown

To delete everything created by this template:

```
az group delete --name rg-hub --yes --no-wait
az group delete --name rg-mgmt --yes --no-wait
az group delete --name rg-avd --yes --no-wait
az group delete --name rg-prod --yes --no-wait
az group delete --name rg-storage --yes --no-wait
```

Adjust the resource group names to match your parameters file if you changed them.

Note: storage account names remain globally reserved for a period after deletion.