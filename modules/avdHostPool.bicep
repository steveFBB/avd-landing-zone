// AVD host pool
//
// Pooled (multi-session) with depth-first load balancing — sessions fill
// one host before spilling onto the next. Cheaper than breadth-first when
// hosts can scale down, but individual host contention is higher.
//
// Registration token is generated at deployment time with a 30-day expiry.
// Session hosts (chunk 6) must register within that window.

param location string
param hostPoolName string
param hostPoolFriendlyName string

@minValue(1)
@maxValue(999)
param maxSessionLimit int

@description('Power hosts on when a user connects. Requires "Desktop Virtualization Power On Contributor" role for the AVD service principal on the session host subscription.')
param startVMOnConnect bool

@description('Preferred app group opened by default in the client. Since chunk 5 deploys a Desktop app group only, this is Desktop. Change to RailApplications if a RemoteApp group becomes the primary experience.')
@allowed([
  'Desktop'
  'RailApplications'
])
param preferredAppGroupType string = 'Desktop'

@description('Registration token expiry. Defaults to 30 days from deployment time. Do not override in the params file unless you have a reason to.')
param registrationExpiryTime string = dateTimeAdd(utcNow(), 'P30D')

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2024-04-03' = {
  name: hostPoolName
  location: location
  properties: {
    friendlyName: hostPoolFriendlyName
    hostPoolType: 'Pooled'
    loadBalancerType: 'DepthFirst'
    maxSessionLimit: maxSessionLimit
    preferredAppGroupType: preferredAppGroupType
    startVMOnConnect: startVMOnConnect
    validationEnvironment: false
    registrationInfo: {
      expirationTime: registrationExpiryTime
      registrationTokenOperation: 'Update'
    }
  }
}

output hostPoolId string = hostPool.id
output hostPoolName string = hostPool.name
