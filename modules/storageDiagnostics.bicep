// Storage account diagnostic settings
//
// Attaches diagnostic settings to both the storage account and its file
// service subresource. The file service is where FSLogix profile activity
// actually happens, so its logs (StorageRead/StorageWrite/StorageDelete)
// are the useful ones for troubleshooting profile mount and I/O issues.
//
// The account-level setting captures transaction metrics for the account
// as a whole; the file-service-level setting captures per-operation logs.

param storageAccountName string
param workspaceId string

@description('Name of the diagnostic setting on the storage account.')
param accountDiagnosticSettingName string

@description('Name of the diagnostic setting on the file service.')
param fileServiceDiagnosticSettingName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' existing = {
  parent: storageAccount
  name: 'default'
}

// Account-level: metrics only. Account-level logs aren't meaningful for
// FSLogix — the operations happen on the file service subresource.
resource accountDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount
  name: accountDiagnosticSettingName
  properties: {
    workspaceId: workspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

// File-service-level: logs and metrics. This is where FSLogix activity
// shows up.
resource fileServiceDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: fileService
  name: fileServiceDiagnosticSettingName
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
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}
