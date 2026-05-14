targetScope = 'subscription'

param location string
param hubRgName string
param mgmtRgName string
param avdRgName string
param prodRgName string
param storageRgName string

resource hubRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: hubRgName
  location: location
}

resource mgmtRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: mgmtRgName
  location: location
}

resource avdRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: avdRgName
  location: location
}

resource prodRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: prodRgName
  location: location
}

resource storageRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: storageRgName
  location: location
}

output hubRgId string = hubRg.id
output mgmtRgId string = mgmtRg.id
output avdRgId string = avdRg.id
output prodRgId string = prodRg.id
output storageRgId string = storageRg.id
