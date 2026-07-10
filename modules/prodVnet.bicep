// Prod VNet
// Contains: prod server subnet
//
// The subnet accepts an optional NSG ID and route table ID. Callers pass
// empty strings for either when they don't want that association.

param location string
param vnetName string
param addressPrefix string
param prodServerSubnet string

@description('NSG resource ID to attach to the prod server subnet. Empty string = no NSG.')
param prodServerNsgId string = ''

@description('Route table resource ID to attach to the prod server subnet. Empty string = no route table.')
param prodServerRouteTableId string = ''

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

resource snetProdServer 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-prod-servers'
  properties: {
    addressPrefix: prodServerSubnet
    networkSecurityGroup: empty(prodServerNsgId) ? null : {
      id: prodServerNsgId
    }
    routeTable: empty(prodServerRouteTableId) ? null : {
      id: prodServerRouteTableId
    }
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
