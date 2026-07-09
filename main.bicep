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
param avdAppsSubnet string

//
// PEERINGS
//
param hubToProdPeeringName string
param prodToHubPeeringName string
param hubToMgmtPeeringName string
param mgmtToHubPeeringName string
param hubToAvdPeeringName string
param avdToHubPeeringName string

@description('Allow forwarded traffic on hub→spoke peerings. Set true when an NVA (e.g. FortiGate) in the hub forwards traffic to spokes.')
param peeringAllowForwardedTrafficHubToSpoke bool = false

@description('Allow forwarded traffic on spoke→hub peerings.')
param peeringAllowForwardedTrafficSpokeToHub bool = false

@description('Allow hub→spoke peerings to offer gateway transit. Set true when a VPN/ER gateway exists in the hub and spokes should use it.')
param peeringAllowGatewayTransitHubToSpoke bool = false

@description('Have spoke→hub peerings use the hub\'s gateway. Set true only when a VPN/ER gateway exists in the hub.')
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
// VNETS
//
module hubVnet 'modules/hubVnet.bicep' = {
  name: 'hubVnet'
  scope: resourceGroup(hubRgName)
  dependsOn: [resourceGroups]
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
  dependsOn: [resourceGroups]
  params: {
    location: location
    vnetName: prodVnetName
    addressPrefix: prodAddressPrefix
    prodServerSubnet: prodServerSubnet
  }
}

module mgmtVnet 'modules/mgmtVnet.bicep' = {
  name: 'mgmtVnet'
  scope: resourceGroup(mgmtRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    vnetName: mgmtVnetName
    addressPrefix: mgmtAddressPrefix
    mgmtServersSubnet: mgmtServersSubnet
    mgmtAdminSubnet: mgmtAdminSubnet
  }
}

module avdVnet 'modules/avdVnet.bicep' = {
  name: 'avdVnet'
  scope: resourceGroup(avdRgName)
  dependsOn: [resourceGroups]
  params: {
    location: location
    vnetName: avdVnetName
    addressPrefix: avdAddressPrefix
    avdSessionHostSubnet: avdSessionHostSubnet
    avdAppsSubnet: avdAppsSubnet
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
// OUTPUTS
//
output hubVnetId string = hubVnet.outputs.vnetId
output prodVnetId string = prodVnet.outputs.vnetId
output mgmtVnetId string = mgmtVnet.outputs.vnetId
output avdVnetId string = avdVnet.outputs.vnetId
output storageAccountId string = fslogix.outputs.storageAccountId
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
