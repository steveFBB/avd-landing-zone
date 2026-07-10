// Placeholder NSG
//
// Creates an NSG with no custom rules — only Azure's default rules apply
// (allow VNet-inbound, allow AzureLoadBalancer-inbound, deny all other
// inbound; allow VNet-outbound, allow Internet-outbound, deny all other
// outbound).
//
// The point of having this NSG is:
//  - The subnet has an NSG attached, so the customer can add rules via
//    portal / CLI later without redeploying the subnet.
//  - Some later features (private endpoints, service endpoints) work
//    better with an NSG attached than without.
//
// Customers layer their own specific rules on top of this once the
// workloads in the subnet are known.

param location string
param nsgName string

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: []
  }
}

output nsgId string = nsg.id
