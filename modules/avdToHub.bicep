// AVD → Hub peering
// Deployed at AVD RG scope.

param hubVnetName string
param avdVnetName string
param avdToHubPeeringName string

@description('Resource group containing the remote (hub) VNet.')
param hubVnetResourceGroup string

@description('Allow traffic forwarded into this spoke from the hub.')
param allowForwardedTraffic bool = false

@description('Whether this spoke offers gateway transit. Always false on spoke→hub.')
param allowGatewayTransit bool = false

@description('Whether this spoke uses the hub\'s gateway. Set true once a VPN/ER gateway exists in the hub.')
param useRemoteGateways bool = false

resource avdVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: avdVnetName
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: hubVnetName
  scope: resourceGroup(hubVnetResourceGroup)
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  parent: avdVnet
  name: avdToHubPeeringName
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
  }
}
