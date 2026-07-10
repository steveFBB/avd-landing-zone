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

param hubAddressPrefix = '10.0.0.0/16'
param prodAddressPrefix = '10.1.0.0/16'
param mgmtAddressPrefix = '10.2.0.0/16'
param avdAddressPrefix = '10.3.0.0/16'

// -----------------------------------------------------------------------------
// SUBNETS
// -----------------------------------------------------------------------------

param gatewaySubnet = '10.0.0.0/24'
param fgtExternal = '10.0.32.0/26'
param fgtInternal = '10.0.32.64/26'
param fgtHa = '10.0.32.128/29'
param fgtMgmt = '10.0.32.160/27'

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

// -----------------------------------------------------------------------------
// FSLOGIX STORAGE
// -----------------------------------------------------------------------------

param storageAccountName = 'fslogixstorageacct001'

param storageSku = 'Premium_LRS'
param storageAccountKind = 'FileStorage'
param storageAccessTier = 'Hot'
param fslogixShareName = 'profiles'
param fslogixShareQuotaGiB = 512

param storageMinimumTlsVersion = 'TLS1_2'
param storageSupportsHttpsTrafficOnly = true
param storageAllowBlobPublicAccess = false
param storageAllowSharedKeyAccess = true

// IMPORTANT: leave 'Enabled' for the initial deployment INCLUDING chunk 4.
// The private endpoint deploys with the account still publicly reachable.
// Flip to 'Disabled' in a follow-up deployment AFTER validating that the
// private endpoint resolves correctly and clients can mount the share via
// the private path. Otherwise all clients — including you — lose access.
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

param hubHasFirewall = false
param hubFirewallInternalIp = ''

param nsgAvdHostsName = 'nsg-avd-hosts'
param nsgProdServersName = 'nsg-prod-servers'
param nsgMgmtServersName = 'nsg-mgmt-servers'
param nsgMgmtAdminName = 'nsg-mgmt-admin'

param routeTableAvdHostsName = 'rt-avd-hosts'
param routeTableProdServersName = 'rt-prod-servers'
param routeTableMgmtServersName = 'rt-mgmt-servers'
param routeTableMgmtAdminName = 'rt-mgmt-admin'

// -----------------------------------------------------------------------------
// PRIVATE ENDPOINT + RBAC (chunk 4)
// -----------------------------------------------------------------------------

// Name of the private endpoint for the FSLogix storage account.
// Convention: pe-<storageAccountName>-file
param fslogixPrivateEndpointName = 'pe-fslogixstorageacct001-file'

// Entra ID object IDs of the groups that get access to the FSLogix share.
//   avdUsersGroupObjectId  — gets Storage File Data SMB Share Contributor
//                             (read/write access to profiles)
//   avdAdminsGroupObjectId — gets Storage File Data SMB Share Elevated
//                             Contributor (read/write + modify NTFS ACLs)
//
// Leave as empty strings if the groups don't exist yet — the role
// assignments are skipped and can be added later by supplying the IDs
// and redeploying.
param avdUsersGroupObjectId = ''
param avdAdminsGroupObjectId = ''
