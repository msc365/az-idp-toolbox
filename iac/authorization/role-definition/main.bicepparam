using './main.bicep'

param managementGroupName = 'mg-alz-intermediate-stg'
param assignableScopes = [
  '/subscriptions/00000000-0000-0000-0000-000000000000' // avengers
  '/subscriptions/00000000-0000-0000-0000-000000000001' // guardians
  '/subscriptions/00000000-0000-0000-0000-000000000002' // galaxy (shared)
  '/providers/Microsoft.Management/managementGroups/${managementGroupName}'
]
