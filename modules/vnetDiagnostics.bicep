// VNet diagnostic settings
//
// Attaches a diagnostic setting to an existing VNet, sending all logs and
// all metrics to the supplied Log Analytics workspace.
//
// This module is scoped to the VNet's resource group and called once per
// VNet from main.bicep.

param vnetName string
param workspaceId string

@description('Name of the diagnostic setting on the VNet.')
param diagnosticSettingName string

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: vnetName
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: vnet
  name: diagnosticSettingName
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
