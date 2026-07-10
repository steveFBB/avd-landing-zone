// AVD VNet
// Contains: session host subnet
//
// The session host subnet has privateEndpointNetworkPolicies set to
// 'Disabled' — historically Azure required this for private endpoints to
// deploy into a subnet. Microsoft has relaxed this restriction but the
// setting is kept explicit here as belt-and-braces and self-documenting.

param location string
param vnetName string
param addressPrefix string
param avdSessionHostSubnet string

@description('NSG resource ID to attach to the AVD session hosts subnet.')
param avdSessionHostNsgId string = ''

@description('Route table resource ID to attach to the AVD session hosts subnet.')
param avdSessionHostRouteTableId string = ''

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
}

resource snetSessionHosts 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-avd-hosts'
  properties: {
    addressPrefix: avdSessionHostSubnet
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroup: empty(avdSessionHostNsgId) ? null : {
      id: avdSessionHostNsgId
    }
    routeTable: empty(avdSessionHostRouteTableId) ? null : {
      id: avdSessionHostRouteTableId
    }
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output sessionHostSubnetId string = snetSessionHosts.id
