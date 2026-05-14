// Hub → Prod peering
// Deployed at hub RG scope. Local VNet is the hub; remote VNet is prod
// (lives in a different RG, referenced via existing+scope).

param hubVnetName string
param prodVnetName string
param hubToProdPeeringName string

@description('Resource group containing the remote (prod) VNet.')
param prodVnetResourceGroup string

@description('Allow traffic forwarded by an NVA/firewall in the hub to reach the spoke. Typically true when a FortiGate or Azure Firewall is in the hub.')
param allowForwardedTraffic bool = false

@description('Allow this peering to act as a gateway path for the spoke. Set true on hub→spoke if the hub has a VPN/ER gateway and spokes should use it.')
param allowGatewayTransit bool = false

@description('Whether this peering should use the remote VNet\'s gateway. Always false on hub→spoke.')
param useRemoteGateways bool = false

// Hub VNet (local to this module's scope)
resource hubVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: hubVnetName
}

// Prod VNet (remote — in a different RG)
resource prodVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: prodVnetName
  scope: resourceGroup(prodVnetResourceGroup)
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  parent: hubVnet
  name: hubToProdPeeringName
  properties: {
    remoteVirtualNetwork: {
      id: prodVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
  }
}
