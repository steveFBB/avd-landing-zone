# AVD Bicep

Infrastructure-as-code for deploying an Azure Virtual Desktop landing zone.

Deploys the network, storage, and control plane needed to host AVD session hosts. Session host provisioning, admin access (Bastion / jump boxes / VPN), and backup are per-customer decisions handled separately.

Deploys:

- 5 resource groups
- Hub-and-spoke networking: 4 VNets (hub, prod, mgmt, avd) with subnets and hub-to-spoke peerings
- FSLogix storage account with SMB file share, private endpoint in the session host subnet, and private DNS zone linked to AVD, hub, and mgmt VNets
- Optional Azure RBAC role assignments on the file share for AVD user and admin groups
- Log Analytics workspace receiving infrastructure diagnostics from VNets and storage accounts. AVD Insights and session host monitoring are outside the scope of this template.
- NSGs on all spoke subnets. The AVD subnet includes documented outbound allow rules for common AVD dependencies. Additional customer-specific security controls are expected.
- Optional route tables forcing spoke traffic through a hub firewall (when `hubHasFirewall = true`)
- AVD control plane: pooled host pool (depth-first), Desktop application group, and workspace

## Architecture

```text
                        Hub VNet (10.0.0.0/16)
                    +--------------------------+
                    | GatewaySubnet            |
                    | Optional NVA subnets     |
                    +-----------+--------------+
                                |
              +-----------------+-----------------+
              |                 |                 |
         hub-to-prod       hub-to-mgmt       hub-to-avd
              |                 |                 |
         Prod VNet          Mgmt VNet         AVD VNet
        (10.1.0.0/16)     (10.2.0.0/16)     (10.3.0.0/16)
              |                 |                 |
         snet-prod-      snet-mgmt-servers    snet-avd-hosts
           servers       snet-mgmt-admin           |
                                                   |
                                          +--------+--------+
                                          |                 |
                                    Session Hosts    Private Endpoint
                                    (out of scope)         |
                                                           |
                                                 FSLogix Storage
                                                 (rg-storage)
                                                    |
                                              Private DNS Zone
                                              (linked to AVD,
                                               hub, mgmt VNets)

               Log Analytics workspace in rg-mgmt
               receives diagnostics from all VNets
               and the storage account
```

## Scope

This is a **greenfield reference deployment** optimised for hub-and-spoke topologies with an optional FortiGate NVA in the hub. It creates all resource groups and VNets itself and does not consume existing hub, DNS, or Log Analytics infrastructure.

The following are handled per customer, outside this template:

- **Session hosts.** VM specs, image (Marketplace / Compute Gallery / Azure Image Builder), join type (Entra ID / Active Directory), and FSLogix client configuration all vary by customer. Session hosts should register with the host pool using a registration token — see [After deployment](#after-deployment) below.
- **Admin access.** Bastion, jump boxes, or existing VPN / ExpressRoute connectivity.
- **Backup.** Recovery Services Vault, backup policies, and protected items — configured once real workloads exist.
- **Azure Files identity-based authentication.** See [FSLogix share readiness](#fslogix-share-readiness) below.

## Known limitations

- Designed for greenfield deployments only. Does not consume existing hub VNets, Log Analytics workspaces, or private DNS zones.
- Assumes a FortiGate-style hub network design (dedicated subnets for external / internal / HA / mgmt NICs).
- Storage account is initially deployed with public network access enabled and must be locked down in a follow-up deployment.
- The FSLogix private endpoint is deployed into the AVD session host subnet for simplicity. A dedicated private endpoint subnet may be preferable in larger environments.
- Does not deploy session hosts.
- Does not configure Azure Files identity-based authentication.
- Does not assign users to the AVD application group.
- Does not deploy Bastion, VPN, backup, or monitoring agents.
- Does not configure AVD Insights, session host monitoring, AMA, or Data Collection Rules.

## Structure

- `main.bicep` — subscription-scoped entry point
- `parameters.example.bicepparam` — example parameters; copy and edit per customer
- `modules/` — per-resource modules

## Prerequisites

- Azure CLI installed (`az --version` to check)
- Bicep CLI installed (`az bicep version` to check; `az bicep install` if missing)
- Contributor or Owner role at the target subscription scope

## Getting started

### Clone the repo locally

Clone the repository somewhere outside OneDrive or other synced folders (file locking can cause intermittent Bicep and Git failures). For example:

```
git clone https://github.com/steveFBB/avd-bicep.git
cd avd-bicep
```

### Open the cloned repo in Studio Code

**File → Open Folder →** select the cloned `avd-bicep` folder.

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
- Each VNet shows its peering to the hub as `Connected` on both sides
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

This deployment currently assumes the storage account is initially deployed with public network access enabled. After validating private endpoint connectivity, redeploy with `storagePublicNetworkAccess = 'Disabled'` in your parameters file. This closes off public internet access to the storage account and forces all clients through the private endpoint.

### 7. (Optional) Grant Power On rights to the AVD service principal

If `startVMOnConnect = true`, the Windows Virtual Desktop service principal needs the "Desktop Virtualization Power On Contributor" role on the subscription where session hosts live. This is a one-time step per subscription, done outside this template.

## FSLogix share readiness

The template creates the storage account, file share, private endpoint, DNS, and Azure RBAC role assignments. **The share is not yet usable by FSLogix.** Before profile mounts will work, you must configure Azure Files identity-based authentication.

Choose one of:

- **AD DS Kerberos** — storage account joined to on-premises Active Directory. For hybrid environments.
- **Microsoft Entra Kerberos** — for Entra-joined session hosts.
- **Microsoft Entra Domain Services** — for environments using Entra Domain Services.

Configure per Microsoft's Azure Files identity guidance. The Azure RBAC assignments created by this template (SMB Share Contributor / Elevated Contributor) control who can access the share, but not what NTFS permissions the files carry — that's a separate step.

After enabling identity-based auth, mount the share from a domain-joined client and set NTFS permissions on the share root using `icacls`. Microsoft publishes the recommended NTFS permission set for FSLogix profile containers.

Until these steps are completed, session hosts will not be able to mount FSLogix profiles from this share.

## After deployment

The landing zone infrastructure is complete, but the AVD environment is not yet operational. To turn it into a working AVD environment:

### 1. Complete FSLogix share readiness

See [FSLogix share readiness](#fslogix-share-readiness) above.

### 2. Get the host pool registration token

The registration token is not exposed as a deployment output because tokens are short-lived operational secrets that should not be stored in Azure deployment history. Retrieve the current token from the AVD host pool with:

```
az desktopvirtualization hostpool retrieve-registration-token \
  --resource-group <avd-rg> \
  --host-pool-name <host-pool-name>
```

If the token has expired, generate a new one:

```
az desktopvirtualization hostpool update \
  --resource-group <avd-rg> \
  --name <host-pool-name> \
  --registration-info expiration-time=<future-iso-timestamp> registration-token-operation=Update
```

### 3. Deploy session hosts

Session hosts should be VMs in `snet-avd-hosts`, joined per customer requirements (Entra ID or Active Directory), with the AVD agent and boot loader extensions registering them against the host pool using the token from step 2.

### 4. Assign users to the application group

The Entra ID group set in `avdUsersGroupObjectId` gets Azure RBAC on the FSLogix share, but does **not** currently get assigned to the AVD application group by this template. Assign users or groups the "Desktop Virtualization User" role on the application group so they can see the desktop in the AVD client:

```
az role assignment create \
  --assignee <group-object-id> \
  --role "Desktop Virtualization User" \
  --scope <application-group-resource-id>
```

### 5. Configure admin access

Bastion, jump box, VPN, ExpressRoute — customer's choice.

### 6. Configure backup

Once real workloads exist, configure a Recovery Services Vault and backup policies for the FSLogix storage account and session host disks.

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