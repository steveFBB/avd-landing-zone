// Private DNS zone for Azure Files privatelink
//
// The zone name is derived from the current Azure environment's storage
// suffix so the template also works in Azure Government (usgovcloudapi.net)
// and Azure China (chinacloudapi.cn) — not just public Azure. The zone
// itself is always deployed to 'global' because private DNS zones are
// non-regional.

param location string = 'global'

// environment().suffixes.storage returns e.g. 'core.windows.net' for public
// Azure. The privatelink zone name for Azure Files is always the storage
// suffix prefixed with 'privatelink.file.'.
var zoneName = 'privatelink.file.${environment().suffixes.storage}'

resource zone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: zoneName
  location: location
}

output zoneId string = zone.id
output zoneName string = zone.name
