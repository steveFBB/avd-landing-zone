// =============================================================================
// AVD foundation — parameters
// =============================================================================
// Every value below is customer-specific and must be reviewed during the
// Customer Decisions / Customer Values worksheets of the runbook before
// deployment. Nothing in this file is a Microsoft default or a "safe" choice.
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
// The AVD address space stays at /16 even though only one subnet is
// currently carved out — leaves room for private endpoint / apps subnets
// to be added later without touching the VNet.
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

// -----------------------------------------------------------------------------
// PEERINGS
// -----------------------------------------------------------------------------

param hubToProdPeeringName = 'hub-to-prod'
param prodToHubPeeringName = 'prod-to-hub'
param hubToMgmtPeeringName = 'hub-to-mgmt'
param mgmtToHubPeeringName = 'mgmt-to-hub'
param hubToAvdPeeringName = 'hub-to-avd'
param avdToHubPeeringName = 'avd-to-hub'

// Note: peering forwarded-traffic flags are derived from hubHasFirewall
// in main.bicep. Set gateway transit flags below when a VPN/ER gateway
// exists in the hub.
//
//   param peeringAllowGatewayTransitHubToSpoke = true
//   param peeringUseRemoteGatewaysSpokeToHub   = true

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
param storageAccessTier = 'Hot'

param fslogixShareName = 'profiles'

// Quota in GiB. Premium file shares are provisioned (pay for the quota).
param fslogixShareQuotaGiB = 512

// --- Storage account security ------------------------------------------------

param storageMinimumTlsVersion = 'TLS1_2'
param storageSupportsHttpsTrafficOnly = true
param storageAllowBlobPublicAccess = false
param storageAllowSharedKeyAccess = true

// IMPORTANT: leave 'Enabled' for the initial deployment so the control
// plane can create the file share. Flip to 'Disabled' in a later deployment
// AFTER the private endpoint (chunk 4) is in place.
param storagePublicNetworkAccess = 'Enabled'

param storageLargeFileSharesState = 'Enabled'

// -----------------------------------------------------------------------------
// LOG ANALYTICS (chunk 2)
// -----------------------------------------------------------------------------

param logAnalyticsWorkspaceName = 'law-avd'
param logAnalyticsRetentionDays = 30
param logAnalyticsSku = 'PerGB2018'

// -----------------------------------------------------------------------------
// NETWORK SECURITY (chunk 3)
// -----------------------------------------------------------------------------

// Master switch. When true:
//   - Route tables are created on all spoke subnets
//   - Default and RFC1918 routes point at hubFirewallInternalIp
//   - Peering forwarded-traffic flags are auto-enabled
//
// When false: no route tables, spokes rely on Azure system routes only.
param hubHasFirewall = false

// Internal IP of the hub firewall NVA. Only used when hubHasFirewall = true.
// Must sit inside fgtInternal (10.0.32.64/26), at .68 or higher.
param hubFirewallInternalIp = ''

// NSG names — one per spoke subnet.
param nsgAvdHostsName = 'nsg-avd-hosts'
param nsgProdServersName = 'nsg-prod-servers'
param nsgMgmtServersName = 'nsg-mgmt-servers'
param nsgMgmtAdminName = 'nsg-mgmt-admin'

// Route table names — used only when hubHasFirewall = true.
param routeTableAvdHostsName = 'rt-avd-hosts'
param routeTableProdServersName = 'rt-prod-servers'
param routeTableMgmtServersName = 'rt-mgmt-servers'
param routeTableMgmtAdminName = 'rt-mgmt-admin'
