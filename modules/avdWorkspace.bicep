// AVD workspace
//
// Groups one or more application groups together for end users. In the
// AVD client, the workspace is what the user "subscribes" to; app groups
// inside it become available desktops and RemoteApps.

param location string
param workspaceName string
param workspaceFriendlyName string

@description('Resource IDs of the application groups to associate with this workspace.')
param applicationGroupReferences array

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2024-04-03' = {
  name: workspaceName
  location: location
  properties: {
    friendlyName: workspaceFriendlyName
    applicationGroupReferences: applicationGroupReferences
  }
}

output workspaceId string = workspace.id
output workspaceName string = workspace.name
