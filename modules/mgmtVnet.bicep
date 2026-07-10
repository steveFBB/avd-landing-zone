// Management VNet
// Contains: mgmt servers subnet, mgmt admin subnet

param location string
param vnetName string
param addressPrefix string
param mgmtServersSubnet string
param mgmtAdminSubnet string

@description('NSG resource ID to attach to the mgmt servers subnet.')
param mgmtServersNsgId string = ''

@description('Route table resource ID to attach to the mgmt servers subnet.')
param mgmtServersRouteTableId string = ''

@description('NSG resource ID to attach to the mgmt admin subnet.')
param mgmtAdminNsgId string = ''

@description('Route table resource ID to attach to the mgmt admin subnet.')
param mgmtAdminRouteTableId string = ''

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
    networkSecurityGroup: empty(mgmtServersNsgId) ? null : {
      id: mgmtServersNsgId
    }
    routeTable: empty(mgmtServersRouteTableId) ? null : {
      id: mgmtServersRouteTableId
    }
  }
}

resource snetMgmtAdmin 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-mgmt-admin'
  properties: {
    addressPrefix: mgmtAdminSubnet
    networkSecurityGroup: empty(mgmtAdminNsgId) ? null : {
      id: mgmtAdminNsgId
    }
    routeTable: empty(mgmtAdminRouteTableId) ? null : {
      id: mgmtAdminRouteTableId
    }
  }
  dependsOn: [
    snetMgmtServers
  ]
}

output vnetId string = vnet.id
output vnetName string = vnet.name
