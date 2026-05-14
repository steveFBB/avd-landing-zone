// Prod VNet
// Contains: prod server subnet

param location string
param vnetName string
param addressPrefix string
param prodServerSubnet string

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
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
