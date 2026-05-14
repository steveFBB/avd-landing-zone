// AVD VNet
// Contains: session host subnet, apps subnet (used in later chunks for
// private endpoints and other AVD-adjacent services)

param location string
param vnetName string
param addressPrefix string
param avdSessionHostSubnet string
param avdAppsSubnet string

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
  }
}

resource snetApps 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-avd-apps'
  properties: {
    addressPrefix: avdAppsSubnet
  }
  dependsOn: [
    snetSessionHosts
  ]
}

output vnetId string = vnet.id
output vnetName string = vnet.name
