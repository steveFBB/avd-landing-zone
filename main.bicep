targetScope = 'subscription'

//
// CORE
//
param location string

//
// RESOURCE GROUPS
//
param hubRgName string
param mgmtRgName string
param avdRgName string
param prodRgName string
param storageRgName string

//
// VNETS
//
param hubVnetName string
param prodVnetName string
param mgmtVnetName string
param avdVnetName string

param hubAddressPrefix string
param prodAddressPrefix string
param mgmtAddressPrefix string
param avdAddressPrefix string

//
// SUBNETS
//
param gatewaySubnet string
param fgtExternal string
param fgtInternal string
param fgtHa string
param fgtMgmt string

param prodServerSubnet string
param mgmtServersSubnet string
param mgmtAdminSubnet string
param avdSessionHostSubnet string

//
// PEERINGS
//
param hubToProdPeeringName string
param prodToHubPeeringName string
param hubToMgmtPeeringName string
param mgmtToHubPeeringName string
param hubToAvdPeeringName string
param avdToHubPeeringName string

@description('Allow hub→spoke peerings to offer gateway transit.')
param peeringAllowGatewayTransitHubToSpoke bool = false

@description('Have spoke→hub peerings use the hub\'s gateway.')
param peeringUseRemoteGatewaysSpokeToHub bool = false

//
// FSLOGIX STORAGE
//
param storageAccountName string
param storageSku string
param storageAccountKind string
param storageAccessTier string
param fslogixShareName string
param fslogixShareQuotaGiB int

param storageMinimumTlsVersion string
param storageSupportsHttpsTrafficOnly bool
param storageAllowBlobPublicAccess bool
param storageAllowSharedKeyAccess bool
param storagePublicNetworkAccess string
param storageLargeFileSharesState string

//
// LOG ANALYTICS (chunk 2)
//
param logAnalyticsWorkspaceName string
param logAnalyticsRetentionDays int
param logAnalyticsSku string

//
// NETWORK SECURITY (chunk 3)
//
param hubHasFirewall bool
param hubFirewallInternalIp string

param nsgAvdHostsName string
param nsgProdServersName string
param nsgMgmtServersName string
param nsgMgmtAdminName string

param routeTableAvdHostsName string
param routeTableProdServersName string
param routeTableMgmtServersName string
param routeTableMgmtAdminName string

//
// PRIVATE ENDPOINT + DNS + RBAC (chunk 4)
//
@description('Name of the private endpoint for the FSLogix storage account.')
param fslogixPrivateEndpointName string

@description('Entra ID object ID of the AVD users group. Empty string skips the role assignment.')
param avdUsersGroupObjectId string = ''

@description('Entra ID object ID of the AVD admins group. Empty string skips the role assignment.')
param avdAdminsGroupObjectId string = ''

//
// DERIVED
//
var peeringAllowForwardedTrafficHubToSpoke = hubHasFirewall
var peeringAllowForwardedTrafficSpokeToHub = hubHasFirewall

//
// RESOURCE GROUPS
//
module resourceGroups 'modules/resourceGroups.bicep' = {
  name: 'resourceGroups'
  params: {
    location: location
    hubRgName: hubRgName
    mgmtRgName: mgmtRgName
    avdRgName: avdRgName
    prodRgName: prodRgName
    storageRgName: storageRgName
  }
}

//
// NSGS (chunk 3)
//
module nsgAvdHosts 'modules/nsgAvdHosts.bicep' = {
  name: 'nsgAvdHosts'
  scope: resourceGroup(avdRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    nsgName: nsgAvdHostsName
  }
}

module nsgProdServers 'modules/nsgPlaceholder.bicep' = {
  name: 'nsgProdServers'
  scope: resourceGroup(prodRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    nsgName: nsgProdServersName
  }
}

module nsgMgmtServers 'modules/nsgPlaceholder.bicep' = {
  name: 'nsgMgmtServers'
  scope: resourceGroup(mgmtRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    nsgName: nsgMgmtServersName
  }
}

module nsgMgmtAdmin 'modules/nsgPlaceholder.bicep' = {
  name: 'nsgMgmtAdmin'
  scope: resourceGroup(mgmtRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    nsgName: nsgMgmtAdminName
  }
}

//
// ROUTE TABLES (chunk 3) — conditional
//
module rtAvdHosts 'modules/routeTableForFirewall.bicep' = if (hubHasFirewall) {
  name: 'rtAvdHosts'
  scope: resourceGroup(avdRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    routeTableName: routeTableAvdHostsName
    firewallInternalIp: hubFirewallInternalIp
  }
}

module rtProdServers 'modules/routeTableForFirewall.bicep' = if (hubHasFirewall) {
  name: 'rtProdServers'
  scope: resourceGroup(prodRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    routeTableName: routeTableProdServersName
    firewallInternalIp: hubFirewallInternalIp
  }
}

module rtMgmtServers 'modules/routeTableForFirewall.bicep' = if (hubHasFirewall) {
  name: 'rtMgmtServers'
  scope: resourceGroup(mgmtRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    routeTableName: routeTableMgmtServersName
    firewallInternalIp: hubFirewallInternalIp
  }
}

module rtMgmtAdmin 'modules/routeTableForFirewall.bicep' = if (hubHasFirewall) {
  name: 'rtMgmtAdmin'
  scope: resourceGroup(mgmtRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    routeTableName: routeTableMgmtAdminName
    firewallInternalIp: hubFirewallInternalIp
  }
}

//
// VNETS
//
module hubVnet 'modules/hubVnet.bicep' = {
  name: 'hubVnet'
  scope: resourceGroup(hubRgName)
  params: {
    location: location
    vnetName: hubVnetName
    addressPrefix: hubAddressPrefix
    gatewaySubnet: gatewaySubnet
    fgtExternal: fgtExternal
    fgtInternal: fgtInternal
    fgtHa: fgtHa
    fgtMgmt: fgtMgmt
  }
}

module prodVnet 'modules/prodVnet.bicep' = {
  name: 'prodVnet'
  scope: resourceGroup(prodRgName)
  params: {
    location: location
    vnetName: prodVnetName
    addressPrefix: prodAddressPrefix
    prodServerSubnet: prodServerSubnet
    prodServerNsgId: nsgProdServers.outputs.nsgId
    prodServerRouteTableId: hubHasFirewall ? rtProdServers!.outputs.routeTableId : ''
  }
}

module mgmtVnet 'modules/mgmtVnet.bicep' = {
  name: 'mgmtVnet'
  scope: resourceGroup(mgmtRgName)
  params: {
    location: location
    vnetName: mgmtVnetName
    addressPrefix: mgmtAddressPrefix
    mgmtServersSubnet: mgmtServersSubnet
    mgmtAdminSubnet: mgmtAdminSubnet
    mgmtServersNsgId: nsgMgmtServers.outputs.nsgId
    mgmtServersRouteTableId: hubHasFirewall ? rtMgmtServers!.outputs.routeTableId : ''
    mgmtAdminNsgId: nsgMgmtAdmin.outputs.nsgId
    mgmtAdminRouteTableId: hubHasFirewall ? rtMgmtAdmin!.outputs.routeTableId : ''
  }
}

module avdVnet 'modules/avdVnet.bicep' = {
  name: 'avdVnet'
  scope: resourceGroup(avdRgName)
  params: {
    location: location
    vnetName: avdVnetName
    addressPrefix: avdAddressPrefix
    avdSessionHostSubnet: avdSessionHostSubnet
    avdSessionHostNsgId: nsgAvdHosts.outputs.nsgId
    avdSessionHostRouteTableId: hubHasFirewall ? rtAvdHosts!.outputs.routeTableId : ''
  }
}

//
// PEERINGS
//
module hubToProd 'modules/hubToProd.bicep' = {
  name: 'hubToProd'
  scope: resourceGroup(hubRgName)
  dependsOn: [hubVnet, prodVnet]
  params: {
    hubVnetName: hubVnetName
    prodVnetName: prodVnetName
    hubToProdPeeringName: hubToProdPeeringName
    prodVnetResourceGroup: prodRgName
    allowForwardedTraffic: peeringAllowForwardedTrafficHubToSpoke
    allowGatewayTransit: peeringAllowGatewayTransitHubToSpoke
    useRemoteGateways: false
  }
}

module prodToHub 'modules/prodToHub.bicep' = {
  name: 'prodToHub'
  scope: resourceGroup(prodRgName)
  dependsOn: [hubVnet, prodVnet]
  params: {
    hubVnetName: hubVnetName
    prodVnetName: prodVnetName
    prodToHubPeeringName: prodToHubPeeringName
    hubVnetResourceGroup: hubRgName
    allowForwardedTraffic: peeringAllowForwardedTrafficSpokeToHub
    allowGatewayTransit: false
    useRemoteGateways: peeringUseRemoteGatewaysSpokeToHub
  }
}

module hubToMgmt 'modules/hubToMgmt.bicep' = {
  name: 'hubToMgmt'
  scope: resourceGroup(hubRgName)
  dependsOn: [hubVnet, mgmtVnet]
  params: {
    hubVnetName: hubVnetName
    mgmtVnetName: mgmtVnetName
    hubToMgmtPeeringName: hubToMgmtPeeringName
    mgmtVnetResourceGroup: mgmtRgName
    allowForwardedTraffic: peeringAllowForwardedTrafficHubToSpoke
    allowGatewayTransit: peeringAllowGatewayTransitHubToSpoke
    useRemoteGateways: false
  }
}

module mgmtToHub 'modules/mgmtToHub.bicep' = {
  name: 'mgmtToHub'
  scope: resourceGroup(mgmtRgName)
  dependsOn: [hubVnet, mgmtVnet]
  params: {
    hubVnetName: hubVnetName
    mgmtVnetName: mgmtVnetName
    mgmtToHubPeeringName: mgmtToHubPeeringName
    hubVnetResourceGroup: hubRgName
    allowForwardedTraffic: peeringAllowForwardedTrafficSpokeToHub
    allowGatewayTransit: false
    useRemoteGateways: peeringUseRemoteGatewaysSpokeToHub
  }
}

module hubToAvd 'modules/hubToAvd.bicep' = {
  name: 'hubToAvd'
  scope: resourceGroup(hubRgName)
  dependsOn: [hubVnet, avdVnet]
  params: {
    hubVnetName: hubVnetName
    avdVnetName: avdVnetName
    hubToAvdPeeringName: hubToAvdPeeringName
    avdVnetResourceGroup: avdRgName
    allowForwardedTraffic: peeringAllowForwardedTrafficHubToSpoke
    allowGatewayTransit: peeringAllowGatewayTransitHubToSpoke
    useRemoteGateways: false
  }
}

module avdToHub 'modules/avdToHub.bicep' = {
  name: 'avdToHub'
  scope: resourceGroup(avdRgName)
  dependsOn: [hubVnet, avdVnet]
  params: {
    hubVnetName: hubVnetName
    avdVnetName: avdVnetName
    avdToHubPeeringName: avdToHubPeeringName
    hubVnetResourceGroup: hubRgName
    allowForwardedTraffic: peeringAllowForwardedTrafficSpokeToHub
    allowGatewayTransit: false
    useRemoteGateways: peeringUseRemoteGatewaysSpokeToHub
  }
}

//
// FSLOGIX STORAGE
//
module fslogix 'modules/fslogixStorage.bicep' = {
  name: 'fslogix'
  scope: resourceGroup(storageRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    storageAccountName: storageAccountName
    storageSku: storageSku
    storageAccountKind: storageAccountKind
    storageAccessTier: storageAccessTier
    fslogixShareName: fslogixShareName
    fslogixShareQuotaGiB: fslogixShareQuotaGiB
    minimumTlsVersion: storageMinimumTlsVersion
    supportsHttpsTrafficOnly: storageSupportsHttpsTrafficOnly
    allowBlobPublicAccess: storageAllowBlobPublicAccess
    allowSharedKeyAccess: storageAllowSharedKeyAccess
    publicNetworkAccess: storagePublicNetworkAccess
    largeFileSharesState: storageLargeFileSharesState
  }
}

//
// LOG ANALYTICS (chunk 2)
//
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  scope: resourceGroup(mgmtRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    workspaceName: logAnalyticsWorkspaceName
    retentionInDays: logAnalyticsRetentionDays
    sku: logAnalyticsSku
  }
}

//
// DIAGNOSTIC SETTINGS (chunk 2)
//
module hubVnetDiag 'modules/vnetDiagnostics.bicep' = {
  name: 'hubVnetDiag'
  scope: resourceGroup(hubRgName)
  dependsOn: [hubVnet]
  params: {
    vnetName: hubVnetName
    workspaceId: logAnalytics.outputs.workspaceId
    diagnosticSettingName: 'diag-to-law'
  }
}

module prodVnetDiag 'modules/vnetDiagnostics.bicep' = {
  name: 'prodVnetDiag'
  scope: resourceGroup(prodRgName)
  dependsOn: [prodVnet]
  params: {
    vnetName: prodVnetName
    workspaceId: logAnalytics.outputs.workspaceId
    diagnosticSettingName: 'diag-to-law'
  }
}

module mgmtVnetDiag 'modules/vnetDiagnostics.bicep' = {
  name: 'mgmtVnetDiag'
  scope: resourceGroup(mgmtRgName)
  dependsOn: [mgmtVnet]
  params: {
    vnetName: mgmtVnetName
    workspaceId: logAnalytics.outputs.workspaceId
    diagnosticSettingName: 'diag-to-law'
  }
}

module avdVnetDiag 'modules/vnetDiagnostics.bicep' = {
  name: 'avdVnetDiag'
  scope: resourceGroup(avdRgName)
  dependsOn: [avdVnet]
  params: {
    vnetName: avdVnetName
    workspaceId: logAnalytics.outputs.workspaceId
    diagnosticSettingName: 'diag-to-law'
  }
}

module fslogixDiag 'modules/storageDiagnostics.bicep' = {
  name: 'fslogixDiag'
  scope: resourceGroup(storageRgName)
  dependsOn: [fslogix]
  params: {
    storageAccountName: storageAccountName
    workspaceId: logAnalytics.outputs.workspaceId
    accountDiagnosticSettingName: 'diag-to-law'
    fileServiceDiagnosticSettingName: 'diag-to-law'
  }
}

//
// PRIVATE DNS ZONE + LINKS (chunk 4)
//
// The zone lives in the storage RG. It's linked to the AVD VNet (session
// hosts must resolve it), the hub VNet (for future on-prem connectivity
// via VPN/ER), and the mgmt VNet (for admin jump boxes).
module privateDnsZoneFiles 'modules/privateDnsZoneFiles.bicep' = {
  name: 'privateDnsZoneFiles'
  scope: resourceGroup(storageRgName)
  dependsOn: [resourceGroups]
}

module dnsLinkAvd 'modules/privateDnsZoneVnetLink.bicep' = {
  name: 'dnsLinkAvd'
  scope: resourceGroup(storageRgName)
  params: {
    zoneName: privateDnsZoneFiles.outputs.zoneName
    linkName: 'link-vnet-avd'
    vnetId: avdVnet.outputs.vnetId
  }
}

module dnsLinkHub 'modules/privateDnsZoneVnetLink.bicep' = {
  name: 'dnsLinkHub'
  scope: resourceGroup(storageRgName)
  params: {
    zoneName: privateDnsZoneFiles.outputs.zoneName
    linkName: 'link-vnet-hub'
    vnetId: hubVnet.outputs.vnetId
  }
}

module dnsLinkMgmt 'modules/privateDnsZoneVnetLink.bicep' = {
  name: 'dnsLinkMgmt'
  scope: resourceGroup(storageRgName)
  params: {
    zoneName: privateDnsZoneFiles.outputs.zoneName
    linkName: 'link-vnet-mgmt'
    vnetId: mgmtVnet.outputs.vnetId
  }
}

//
// PRIVATE ENDPOINT (chunk 4)
//
// Lives in the storage RG (where the storage account is) but the PE's NIC
// consumes an IP from the AVD session host subnet.
module fslogixPrivateEndpoint 'modules/fslogixPrivateEndpoint.bicep' = {
  name: 'fslogixPrivateEndpoint'
  scope: resourceGroup(storageRgName)
  params: {
    location: location
    privateEndpointName: fslogixPrivateEndpointName
    subnetId: avdVnet.outputs.sessionHostSubnetId
    storageAccountId: fslogix.outputs.storageAccountId
    privateDnsZoneId: privateDnsZoneFiles.outputs.zoneId
  }
}

//
// FSLOGIX RBAC (chunk 4)
//
// Grants the AVD user and admin groups access to the file share. Both
// group IDs are optional — assignments are skipped when empty.
module fslogixRbac 'modules/fslogixRbac.bicep' = {
  name: 'fslogixRbac'
  scope: resourceGroup(storageRgName)
  dependsOn: [fslogix]
  params: {
    storageAccountName: storageAccountName
    fileShareName: fslogixShareName
    avdUsersGroupObjectId: avdUsersGroupObjectId
    avdAdminsGroupObjectId: avdAdminsGroupObjectId
  }
}

//
// OUTPUTS
//
output hubVnetId string = hubVnet.outputs.vnetId
output prodVnetId string = prodVnet.outputs.vnetId
output mgmtVnetId string = mgmtVnet.outputs.vnetId
output avdVnetId string = avdVnet.outputs.vnetId
output storageAccountId string = fslogix.outputs.storageAccountId
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output privateDnsZoneId string = privateDnsZoneFiles.outputs.zoneId
