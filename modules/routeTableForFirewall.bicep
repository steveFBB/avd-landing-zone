// Route table for spoke subnets when a firewall is in the hub
//
// Forces all traffic from the associated subnet through the hub firewall:
//   - Default route (0.0.0.0/0) → firewall internal IP
//   - RFC1918 routes (10/8, 172.16/12, 192.168/16) → firewall internal IP
//
// The RFC1918 routes are the important ones for hub-and-spoke: without
// them, spoke-to-spoke traffic follows the peering directly and bypasses
// the firewall entirely, which defeats the purpose.
//
// This module is only deployed when hubHasFirewall = true in main.bicep.

param location string
param routeTableName string
param firewallInternalIp string

resource routeTable 'Microsoft.Network/routeTables@2024-01-01' = {
  name: routeTableName
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'default-via-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallInternalIp
        }
      }
      {
        name: 'rfc1918-10-via-firewall'
        properties: {
          addressPrefix: '10.0.0.0/8'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallInternalIp
        }
      }
      {
        name: 'rfc1918-172-via-firewall'
        properties: {
          addressPrefix: '172.16.0.0/12'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallInternalIp
        }
      }
      {
        name: 'rfc1918-192-via-firewall'
        properties: {
          addressPrefix: '192.168.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallInternalIp
        }
      }
    ]
  }
}

output routeTableId string = routeTable.id
