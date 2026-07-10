// AVD session host NSG
//
// Baseline outbound rules following Microsoft's documented AVD network
// requirements. All AVD service traffic is outbound-only; there are no
// required inbound rules from the internet.
//
// Customers typically add further rules on top (e.g. specific outbound
// restrictions, allow inbound from a Bastion subnet, etc.).

param location string
param nsgName string

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowOutbound-WindowsVirtualDesktop'
        properties: {
          description: 'Required: AVD service control plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'WindowsVirtualDesktop'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowOutbound-AzureFrontDoorFrontend'
        properties: {
          description: 'Required: AVD reverse-connect / gateway'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureFrontDoor.Frontend'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowOutbound-AzureMonitor'
        properties: {
          description: 'Required: agent health monitoring'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowOutbound-AzureCloud'
        properties: {
          description: 'Required: various Azure control plane calls (auth, gallery, etc.)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowOutbound-Storage'
        properties: {
          description: 'Required: agent updates, image gallery, FSLogix (when public endpoint used)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyInbound-Internet'
        properties: {
          description: 'Explicit deny for inbound from internet (belt-and-braces vs default rules)'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
    ]
  }
}

output nsgId string = nsg.id
