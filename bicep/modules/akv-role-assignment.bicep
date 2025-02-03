param keyVaultName string
param principalId string
param principalType string = 'ServicePrincipal'
param roleIds array

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleId in roleIds: {
  name: guid(subscription().subscriptionId, resourceGroup().name, keyVaultName, roleId, principalId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalId
    principalType: principalType
  }
}]
