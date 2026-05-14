// Hub → AVD peering
// Deployed at hub RG scope.

param hubVnetName string
param avdVnetName string
param hubToAvdPeeringName string

@description('Resource group containing the remote (AVD) VNet.')
param avdVnetResourceGroup string

@description('Allow traffic forwarded by an NVA/firewall in the hub to reach the spoke.')
param allowForwardedTraffic bool = false

@description('Allow this peering to act as a gateway path for the spoke.')
param allowGatewayTransit bool = false

@description('Whether this peering should use the remote VNet\'s gateway. Always false on hub→spoke.')
param useRemoteGateways bool = false

resource hubVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: hubVnetName
}

resource avdVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: avdVnetName
  scope: resourceGroup(avdVnetResourceGroup)
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  parent: hubVnet
  name: hubToAvdPeeringName
  properties: {
    remoteVirtualNetwork: {
      id: avdVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
  }
}
