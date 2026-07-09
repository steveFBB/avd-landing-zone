// Log Analytics workspace
//
// Deployed at the RG scope of the module caller (main.bicep places this in
// rg-mgmt, alongside the mgmt VNet).
//
// Retention and SKU are parameterised so different customers can pick
// different values in their parameters file.

param location string
param workspaceName string

@description('Data retention in days. Azure defaults to 30. Valid range 30–730.')
@minValue(30)
@maxValue(730)
param retentionInDays int

@allowed([
  'PerGB2018'
  'CapacityReservation'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
@description('Workspace SKU. PerGB2018 is the modern pay-as-you-go SKU and the recommended choice for new deployments.')
param sku string

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output workspaceId string = workspace.id
output workspaceName string = workspace.name
