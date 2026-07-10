// RBAC role assignments on the FSLogix file share
//
// Grants two Entra ID groups access to the file share:
//   - Users group  →  Storage File Data SMB Share Contributor (read/write)
//   - Admins group →  Storage File Data SMB Share Elevated Contributor
//                     (read/write + modify NTFS ACLs)
//
// Both group object IDs are optional — if empty, no assignment is created.
// This lets the template deploy cleanly before the customer has created
// the groups; they can be added later by supplying the IDs and redeploying.
//
// Role definition IDs are Microsoft's built-in ones and never change.
//   - SMB Share Contributor:          0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb
//   - SMB Share Elevated Contributor: a7264617-510b-434b-a828-9731dc254ea7

param storageAccountName string
param fileShareName string

@description('Entra ID object ID of the AVD users group. Empty string skips the assignment.')
param avdUsersGroupObjectId string = ''

@description('Entra ID object ID of the AVD admins group. Empty string skips the assignment.')
param avdAdminsGroupObjectId string = ''

var smbShareContributorRoleId = '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
var smbShareElevatedContributorRoleId = 'a7264617-510b-434b-a828-9731dc254ea7'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' existing = {
  parent: storageAccount
  name: 'default'
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' existing = {
  parent: fileService
  name: fileShareName
}

resource usersAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(avdUsersGroupObjectId)) {
  scope: fileShare
  name: guid(fileShare.id, avdUsersGroupObjectId, smbShareContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', smbShareContributorRoleId)
    principalId: avdUsersGroupObjectId
    principalType: 'Group'
  }
}

resource adminsAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(avdAdminsGroupObjectId)) {
  scope: fileShare
  name: guid(fileShare.id, avdAdminsGroupObjectId, smbShareElevatedContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', smbShareElevatedContributorRoleId)
    principalId: avdAdminsGroupObjectId
    principalType: 'Group'
  }
}
