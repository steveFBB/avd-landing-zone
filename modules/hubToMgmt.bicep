// Hub → Mgmt peering
// Deployed at hub RG scope.

param hubVnetName string
param mgmtVnetName string
param hubToMgmtPeeringName string

@description('Resource group containing the remote (mgmt) VNet.')
param mgmtVnetResourceGroup string

@description('Allow traffic forwarded by an NVA/firewall in the hub to reach the spoke.')
param allowForwardedTraffic bool = false

@description('Allow this peering to act as a gateway path for the spoke.')
param allowGatewayTransit bool = false

@description('Whether this peering should use the remote VNet\'s gateway. Always false on hub→spoke.')
param useRemoteGateways bool = false

resource hubVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: hubVnetName
}

resource mgmtVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: mgmtVnetName
  scope: resourceGroup(mgmtVnetResourceGroup)
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  parent: hubVnet
  name: hubToMgmtPeeringName
  properties: {
    remoteVirtualNetwork: {
      id: mgmtVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
  }
}
