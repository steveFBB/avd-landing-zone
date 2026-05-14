// FSLogix storage account + file share
//
// Security and tier settings are all parameterised — no defaults baked in
// here. The customer decides via parameters.bicepparam whether they want
// premium/standard, replication, TLS, public access, etc.
//
// Notes for the engineer:
//  - Premium SKU (Premium_LRS/ZRS) requires kind = 'FileStorage'.
//  - Standard SKUs (Standard_LRS/ZRS/GRS/RAGRS) go with kind = 'StorageV2'.
//  - publicNetworkAccess MUST remain 'Enabled' until the private endpoint
//    is deployed (chunk 3), otherwise the file share creation in this
//    template will fail because the control plane can't reach the data
//    plane. Flip to 'Disabled' in a later deployment.

param location string

param storageAccountName string

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param storageSku string

@allowed([
  'StorageV2'
  'FileStorage'
])
param storageAccountKind string

@allowed([
  'Hot'
  'Cool'
])
param storageAccessTier string

param fslogixShareName string
param fslogixShareQuotaGiB int

@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
  'TLS1_3'
])
param minimumTlsVersion string

param supportsHttpsTrafficOnly bool
param allowBlobPublicAccess bool
param allowSharedKeyAccess bool

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string

@allowed([
  'Enabled'
  'Disabled'
])
param largeFileSharesState string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: storageAccountKind
  properties: {
    accessTier: storageAccessTier
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    publicNetworkAccess: publicNetworkAccess
    largeFileSharesState: largeFileSharesState
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource fslogixShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  parent: fileServices
  name: fslogixShareName
  properties: {
    shareQuota: fslogixShareQuotaGiB
    enabledProtocols: 'SMB'
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output fslogixShareName string = fslogixShare.name
