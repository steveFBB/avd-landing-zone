// AVD VNet
// Contains: session host subnet, apps subnet

param location string
param vnetName string
param addressPrefix string
param avdSessionHostSubnet string
param avdAppsSubnet string

@description('NSG resource ID to attach to the AVD session hosts subnet.')
param avdSessionHostNsgId string = ''

@description('Route table resource ID to attach to the AVD session hosts subnet.')
param avdSessionHostRouteTableId string = ''

@description('NSG resource ID to attach to the AVD apps subnet.')
param avdAppsNsgId string = ''

@description('Route table resource ID to attach to the AVD apps subnet.')
param avdAppsRouteTableId string = ''

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

resource snetApps 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-avd-apps'
  properties: {
    addressPrefix: avdAppsSubnet
    networkSecurityGroup: empty(avdAppsNsgId) ? null : {
      id: avdAppsNsgId
    }
    routeTable: empty(avdAppsRouteTableId) ? null : {
      id: avdAppsRouteTableId
    }
  }
  dependsOn: [
    snetSessionHosts
  ]
}

output vnetId string = vnet.id
output vnetName string = vnet.name
