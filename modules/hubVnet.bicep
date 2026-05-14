// Hub VNet
// Contains: GatewaySubnet, FortiGate external/internal/HA/mgmt subnets
// Subnets are declared as separate child resources rather than inline,
// so NSGs and route tables can be attached in later chunks without
// redeploying the VNet itself.

param location string
param vnetName string
param addressPrefix string

param gatewaySubnet string
param fgtExternal string
param fgtInternal string
param fgtHa string
param fgtMgmt string

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

resource snetGateway 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: gatewaySubnet
  }
}

resource snetFgtExternal 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-fgt-external'
  properties: {
    addressPrefix: fgtExternal
  }
  // Subnets must be deployed serially within a VNet — Azure will throw a
  // conflict if multiple subnet operations run in parallel on the same VNet.
  dependsOn: [
    snetGateway
  ]
}

resource snetFgtInternal 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-fgt-internal'
  properties: {
    addressPrefix: fgtInternal
  }
  dependsOn: [
    snetFgtExternal
  ]
}

resource snetFgtHa 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-fgt-ha'
  properties: {
    addressPrefix: fgtHa
  }
  dependsOn: [
    snetFgtInternal
  ]
}

resource snetFgtMgmt 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'snet-fgt-mgmt'
  properties: {
    addressPrefix: fgtMgmt
  }
  dependsOn: [
    snetFgtHa
  ]
}

output vnetId string = vnet.id
output vnetName string = vnet.name
