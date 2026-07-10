// Private endpoint for the FSLogix storage account
//
// Deploys the PE into the session host subnet with a group ID of 'file'
// (which targets the file service subresource, not blob/queue/table).
// Also wires up the DNS zone group so the PE's IP address is automatically
// registered in the private DNS zone.
//
// The subnet must have privateEndpointNetworkPolicies = 'Disabled' — that's
// handled in avdVnet.bicep in chunk 4.

param location string
param privateEndpointName string
param subnetId string
param storageAccountId string
param privateDnsZoneId string

resource pe 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
}

// DNS zone group — auto-registers the PE's private IP as an A record in
// the private DNS zone. Without this, the PE gets a private IP but no DNS
// resolution, and clients fall back to the public endpoint (which defeats
// the whole purpose).
resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: pe
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-file-core-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

output privateEndpointId string = pe.id
