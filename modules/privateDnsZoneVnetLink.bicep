// VNet-to-private-DNS-zone link
//
// Reusable module — called once per VNet that needs to resolve the zone.
// Zone lives in one RG; each link is deployed at the zone's RG scope but
// references a VNet that may live elsewhere.

param zoneName string
param linkName string
param vnetId string

@description('Register the VNet\'s own DNS records into the zone. Almost always false for privatelink zones — leave off unless you have a specific reason.')
param registrationEnabled bool = false

resource zone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: zoneName
}

resource link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: zone
  name: linkName
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: registrationEnabled
  }
}
