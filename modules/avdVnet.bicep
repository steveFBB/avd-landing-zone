// AVD VNet
// Contains: session host subnet
//
// Note: an "apps" subnet was previously defined here for private endpoints
// and other AVD-adjacent services. It was removed because no resource in
// the template used it. The AVD VNet address space stays wide (10.3.0.0/16)
// so a dedicated subnet can be added later without touching the VNet.

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
