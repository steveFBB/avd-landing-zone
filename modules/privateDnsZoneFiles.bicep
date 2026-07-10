// Private DNS zone for Azure Files privatelink
//
// The zone name is fixed by Azure — Azure Files private endpoints publish
// their A records to exactly this zone, so parameterising it would be a
// footgun.
//
// This module creates just the zone. VNet links are separate resources
// (see privateDnsZoneVnetLink.bicep) so each VNet-to-zone link can be
// deployed idempotently from any RG.

param location string = 'global'  // Private DNS zones are always global

resource zone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.file.core.windows.net'
  location: location
}

output zoneId string = zone.id
output zoneName string = zone.name
