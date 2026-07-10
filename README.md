# AVD Bicep

Infrastructure-as-code for deploying Azure Virtual Desktop landing zones.

Deploys:

- 5 resource groups
- Hub-and-spoke networking: 4 VNets (hub, prod, mgmt, avd) with subnets and full-mesh peerings
- FSLogix storage account with SMB file share, private endpoint in the session host subnet, and private DNS zone linked to AVD, hub, and mgmt VNets
- Optional RBAC role assignments on the file share for AVD user and admin groups
- Log Analytics workspace with diagnostic settings on VNets and storage
- NSGs on all spoke subnets (AVD baseline rules on session hosts, placeholders elsewhere)
- Optional route tables forcing spoke traffic through a hub firewall (when `hubHasFirewall = true`)
- AVD control plane: pooled host pool (depth-first), Desktop application group, and workspace

## Structure

- `main.bicep` — subscription-scoped entry point
- `parameters.example.bicepparam` — example parameters; copy and edit per customer
- `modules/` — per-resource modules

## Status

**Chunk 1 complete:** foundation networking (4 VNets, subnets, peerings) and FSLogix storage account.

**Chunk 2 complete:** Log Analytics workspace and diagnostic settings on VNets and storage.

**Chunk 3 complete:** NSGs on all spoke subnets with AVD baseline rules on the session host NSG; conditional route tables that forward traffic through a hub firewall when `hubHasFirewall = true`.

**Chunk 4 complete:** private endpoint for the FSLogix file share, private DNS zone linked to AVD/hub/mgmt VNets, and optional RBAC role assignments on the file share.

**Chunk 5 complete:** AVD control plane — pooled host pool with depth-first load balancing, Desktop application group, and workspace.

### Roadmap

- Chunk 6 — Session hosts
- Chunk 7 — Bastion
- Chunk 8 — Backup and alerts

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
git clone https://github.com/steveFBB/avd-bicep.git
cd avd-bicep
```

If `C:\Projects` already exists, you'll get an error on the first line — ignore it and continue.

### Open the cloned repo in Studio Code

**File → Open Folder →** select `C:\Projects\avd-bicep`.

### Recommended extensions

- **Bicep** (publisher: Microsoft) — syntax highlighting and inline validation for `.bicep` files
- **Azure CLI Tools** (optional) — helpful for running `az` commands

## Running the deployment

Placeholders like `<region>` and `<customer>` need to be replaced with real values each time. You can't just copy and paste.

### 1. Create a customer-specific parameters file

Copy the example and edit for the target environment. Real customer files are gitignored (only `parameters.example.bicepparam` gets committed):

```
copy parameters.example.bicepparam parameters.<customer>.bicepparam
```

Open the new file and set at minimum:

- `location` — Azure region (e.g. `westus`, `uksouth`)
- `storageAccountName` — globally unique, lowercase letters and digits, 3–24 chars
- `logAnalyticsWorkspaceName` — must be unique within the resource group
- `hubHasFirewall` — `true` if a firewall NVA exists in the hub VNet, otherwise `false`
- `hubFirewallInternalIp` — required when `hubHasFirewall = true`; the firewall's internal NIC IP
- `fslogixPrivateEndpointName` — private endpoint name for the FSLogix storage account
- `avdUsersGroupObjectId` — Entra ID group object ID for AVD users (optional; empty skips the role assignment)
- `avdAdminsGroupObjectId` — Entra ID group object ID for AVD admins (optional; empty skips the role assignment)
- `hostPoolName`, `workspaceName`, `applicationGroupName` — internal resource names
- `hostPoolFriendlyName`, `workspaceFriendlyName`, `applicationGroupFriendlyName` — what end users see in the AVD client
- `maxSessionLimit` — max concurrent sessions per session host (depends on VM size — typically 6–20)
- `startVMOnConnect` — power on hosts when a user connects; requires additional RBAC on the AVD service principal
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

If you see resources marked as **modify** or **delete**, stop and read carefully — you may be about to change something that already exists in the subscription.

### 4. Deploy

```
az deployment sub create --location <region> --name "avd-foundation" --template-file main.bicep --parameters parameters.<customer>.bicepparam
```

Deployment takes 5–10 minutes.

### 5. Validate

Check in the Azure Portal:

- All five resource groups exist
- Each VNet shows its peerings as `Connected` on both sides
- FSLogix storage account has the `profiles` file share
- Log Analytics workspace exists in the mgmt resource group
- Each VNet and the storage account has a diagnostic setting pointing at the workspace
- Each spoke subnet has an NSG attached
- If `hubHasFirewall = true`: each spoke subnet also has a route table attached with routes pointing at the firewall internal IP
- Private DNS zone `privatelink.file.core.windows.net` exists with links to AVD, hub, and mgmt VNets
- Private endpoint exists for the FSLogix storage account and has an A record in the private DNS zone
- AVD host pool, application group, and workspace exist in the AVD resource group
- The workspace shows the application group under Application groups

### 6. Lock down public access to the storage account

Once validated that clients can reach the file share via the private endpoint, run a follow-up deployment with `storagePublicNetworkAccess` changed to `'Disabled'` in your parameters file. This closes off public internet access to the storage account and forces all clients through the private endpoint.

### 7. (Optional) Grant Power On rights to the AVD service principal

If `startVMOnConnect = true`, the Windows Virtual Desktop service principal needs the "Desktop Virtualization Power On Contributor" role on the subscription where session hosts live. This is a one-time step per subscription, done outside this template.

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

Note: storage account names remain globally reserved for a period after deletion. Log Analytics workspaces are soft-deleted for 14 days by default before permanent removal. Private DNS zones cannot be deleted while VNet links exist — deletion of the storage resource group handles this automatically.