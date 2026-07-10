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
// Flip to 'Disabled' in a follow-up deployment AFTER validating that the
// private endpoint resolves correctly and clients can mount the share.
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

param fslogixPrivateEndpointName = 'pe-fslogixstorageacct001-file'

param avdUsersGroupObjectId = ''
param avdAdminsGroupObjectId = ''

// -----------------------------------------------------------------------------
// AVD CONTROL PLANE (chunk 5)
// -----------------------------------------------------------------------------

// Resource names — internal identifiers, kept short and functional.
param hostPoolName = 'hp-avd'
param workspaceName = 'ws-avd'
param applicationGroupName = 'ag-avd-desktop'

// Friendly names — what end users see in the AVD client.
param hostPoolFriendlyName = 'AVD Host Pool'
param workspaceFriendlyName = 'AVD Workspace'
param applicationGroupFriendlyName = 'Desktop'

// Max concurrent sessions per session host. Depends on VM size — typical
// ranges: 2-vCPU/8GB VMs handle ~6-8, 4-vCPU/16GB handle ~10-12,
// 8-vCPU/32GB handle ~16-20. Customer-tunable.
param maxSessionLimit = 10

// Power hosts on when a user connects. Cost saver — hosts can be powered
// off when idle and auto-start on demand. Requires the AVD service
// principal to have "Desktop Virtualization Power On Contributor" on the
// subscription where session hosts live. Skip this if scaling plans are
// managing power state instead.
param startVMOnConnect = false
