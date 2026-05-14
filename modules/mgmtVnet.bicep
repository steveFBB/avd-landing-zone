// Management VNet
// Contains: mgmt servers subnet, mgmt admin subnet

param location string
param vnetName string
param addressPrefix string
param mgmtServersSubnet string
param mgmtAdminSubnet string

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

resource snetMgmtServers 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-mgmt-servers'
  properties: {
    addressPrefix: mgmtServersSubnet
  }
}

resource snetMgmtAdmin 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-mgmt-admin'
  properties: {
    addressPrefix: mgmtAdminSubnet
  }
  dependsOn: [
    snetMgmtServers
  ]
}

output vnetId string = vnet.id
output vnetName string = vnet.name
