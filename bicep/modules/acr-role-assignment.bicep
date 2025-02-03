param acrName string
param principalId string
param principalType string = 'ServicePrincipal'
param roleIds array

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleId in roleIds: {
  name: guid(subscription().subscriptionId, resourceGroup().name, acrName, roleId, principalId)
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalId
    principalType: principalType
  }
}]
