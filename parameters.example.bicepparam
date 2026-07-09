// =============================================================================
// AVD foundation — parameters
// =============================================================================
// Every value below is customer-specific and must be reviewed during the
// Customer Decisions / Customer Values worksheets of the runbook before
// deployment. Nothing in this file is a Microsoft default or a "safe" choice.
//
// Deploy with:
//   az deployment sub create \
//     --location <location> \
//     --template-file main.bicep \
//     --parameters parameters.bicepparam
// =============================================================================

using 'main.bicep'

// -----------------------------------------------------------------------------
// CORE
// -----------------------------------------------------------------------------

// Azure region all resources deploy to.
// Examples: 'australiaeast', 'uksouth', 'westeurope', 'westus'
param location = 'westus'

// -----------------------------------------------------------------------------
// RESOURCE GROUPS
// -----------------------------------------------------------------------------

param hubRgName = 'rg-hub'
param mgmtRgName = 'rg-mgmt'
param avdRgName = 'rg-avd'
param prodRgName = 'rg-prod'
param storageRgName = 'rg-storage'

// -----------------------------------------------------------------------------
// VNETS
// -----------------------------------------------------------------------------

param hubVnetName = 'vnet-hub'
param prodVnetName = 'vnet-prod'
param mgmtVnetName = 'vnet-mgmt'
param avdVnetName = 'vnet-avd'

// Each VNet's overall address space. Subnets below must fit within these.
param hubAddressPrefix = '10.0.0.0/16'
param prodAddressPrefix = '10.1.0.0/16'
param mgmtAddressPrefix = '10.2.0.0/16'
param avdAddressPrefix = '10.3.0.0/16'

// -----------------------------------------------------------------------------
// SUBNETS
// -----------------------------------------------------------------------------

// Hub subnets — gateway subnet plus FortiGate NICs.
// GatewaySubnet name is fixed by Azure (do not rename).
param gatewaySubnet = '10.0.0.0/24'
param fgtExternal = '10.0.32.0/26'
param fgtInternal = '10.0.32.64/26'
param fgtHa = '10.0.32.128/29'
param fgtMgmt = '10.0.32.160/27'

// Spoke subnets.
param prodServerSubnet = '10.1.0.0/24'
param mgmtServersSubnet = '10.2.0.0/24'
param mgmtAdminSubnet = '10.2.1.0/24'
param avdSessionHostSubnet = '10.3.0.0/24'
param avdAppsSubnet = '10.3.1.0/24'

// -----------------------------------------------------------------------------
// PEERINGS
// -----------------------------------------------------------------------------

param hubToProdPeeringName = 'hub-to-prod'
param prodToHubPeeringName = 'prod-to-hub'
param hubToMgmtPeeringName = 'hub-to-mgmt'
param mgmtToHubPeeringName = 'mgmt-to-hub'
param hubToAvdPeeringName = 'hub-to-avd'
param avdToHubPeeringName = 'avd-to-hub'

// Peering behaviour flags. Defaults in main.bicep are all `false` (safe for
// a hub-and-spoke with no Azure gateway yet). Override when the topology
// grows — e.g. set peeringAllowForwardedTrafficHubToSpoke = true once the
// FortiGate is forwarding traffic, and the *UseRemoteGateways pair once an
// Azure VPN/ER gateway is deployed in the hub.
//
//   param peeringAllowForwardedTrafficHubToSpoke = true
//   param peeringAllowForwardedTrafficSpokeToHub = true
//   param peeringAllowGatewayTransitHubToSpoke   = true
//   param peeringUseRemoteGatewaysSpokeToHub     = true

// -----------------------------------------------------------------------------
// FSLOGIX STORAGE
// -----------------------------------------------------------------------------

// Storage account name — must be globally unique, 3–24 chars, lowercase + digits.
param storageAccountName = 'fslogixstorageacct001'

// SKU and kind MUST be compatible:
//   - Premium_LRS / Premium_ZRS  →  storageAccountKind = 'FileStorage'
//   - Standard_*                 →  storageAccountKind = 'StorageV2'
// Premium is strongly recommended for FSLogix profile performance.
param storageSku = 'Premium_LRS'
param storageAccountKind = 'FileStorage'

// Access tier — for FileStorage this is 'Hot' (the only valid value).
// For StorageV2 you may also use 'Cool'.
param storageAccessTier = 'Hot'

param fslogixShareName = 'profiles'

// Quota in GiB. Premium file shares are provisioned (pay for the quota,
// not consumption); standard shares are pay-as-you-go up to the limit.
param fslogixShareQuotaGiB = 512

// --- Storage account security ------------------------------------------------

// Minimum TLS version accepted by the storage account.
// 'TLS1_2' is the recommended baseline; 'TLS1_3' if all clients support it.
param storageMinimumTlsVersion = 'TLS1_2'

// Force HTTPS for blob/queue/table endpoints (does not affect SMB).
param storageSupportsHttpsTrafficOnly = true

// Allow anonymous public blob access at the account level. Should be false
// for FSLogix — profiles are private.
param storageAllowBlobPublicAccess = false

// Allow shared-key (access key) authentication. FSLogix with Entra Kerberos
// can in principle disable this, but the initial file share creation in
// this template still requires it. Leave true for now; revisit in chunk 3.
param storageAllowSharedKeyAccess = true

// IMPORTANT: leave 'Enabled' for the initial deployment so the control
// plane can create the file share. Flip to 'Disabled' in a later deployment
// AFTER the private endpoint (chunk 3) is in place — otherwise no client
// will be able to mount the share.
param storagePublicNetworkAccess = 'Enabled'

// Required if quota > 5 TiB. Harmless if not. Recommended 'Enabled'.
param storageLargeFileSharesState = 'Enabled'

// -----------------------------------------------------------------------------
// LOG ANALYTICS (chunk 2)
// -----------------------------------------------------------------------------

// Workspace lives in the mgmt RG alongside the mgmt VNet.
param logAnalyticsWorkspaceName = 'law-avd'

// Data retention in days. Azure default is 30. Valid range 30–730.
// Common choices: 30 (default), 90 (compliance), 180+ (long-term audit).
param logAnalyticsRetentionDays = 30

// Workspace SKU. PerGB2018 is the modern pay-as-you-go SKU — recommended
// for all new workspaces. Older SKUs exist for legacy reasons only.
param logAnalyticsSku = 'PerGB2018'
