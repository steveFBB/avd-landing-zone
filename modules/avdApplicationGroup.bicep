// AVD desktop application group
//
// Every host pool needs at least one application group. Desktop type gives
// users a full desktop session. RemoteApp is a separate concept and would
// be added as a second app group in a future chunk if needed.

param location string
param applicationGroupName string
param applicationGroupFriendlyName string
param hostPoolId string

resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2024-04-03' = {
  name: applicationGroupName
  location: location
  properties: {
    friendlyName: applicationGroupFriendlyName
    applicationGroupType: 'Desktop'
    hostPoolArmPath: hostPoolId
  }
}

output applicationGroupId string = appGroup.id
output applicationGroupName string = appGroup.name
