// Prod → Hub peering
// Deployed at prod RG scope. Local VNet is prod; remote is hub.

param hubVnetName string
param prodVnetName string
param prodToHubPeeringName string

@description('Resource group containing the remote (hub) VNet.')
param hubVnetResourceGroup string

@description('Allow traffic forwarded into this spoke from the hub (e.g. via an NVA in another spoke). Typically true in hub-and-spoke with an NVA.')
param allowForwardedTraffic bool = false

@description('Whether this spoke offers gateway transit. Always false on spoke→hub.')
param allowGatewayTransit bool = false

@description('Whether this spoke uses the hub\'s gateway. Set true once a VPN/ER gateway exists in the hub.')
param useRemoteGateways bool = false

resource prodVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: prodVnetName
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: hubVnetName
  scope: resourceGroup(hubVnetResourceGroup)
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  parent: prodVnet
  name: prodToHubPeeringName
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
