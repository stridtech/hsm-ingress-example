@description('Name of the KeyVault for retrieval')
param keyVaultName string

param resourceGroupLocation string

param oidc_issuer_url string

param environment_short string

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

@description('This is the built-in Key Key Vault Secrets User role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-user')
resource keyVaultSecretsUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

@description('This is the built-in Key Key Vault Reader role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-reader')
resource keyVaultReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '21090545-7ca7-4776-b22c-e363652d74d2'
}

resource controllerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${environment_short}-uai-controller'
  location: resourceGroupLocation
}

resource keyVaultSecretsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, controllerIdentity.name, keyVaultSecretsUserRoleDefinition.id)
  properties: {
    roleDefinitionId: keyVaultSecretsUserRoleDefinition.id
    principalId: controllerIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, controllerIdentity.name, keyVaultReaderRoleDefinition.id)
  properties: {
    roleDefinitionId: keyVaultReaderRoleDefinition.id
    principalId: controllerIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource federatedCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: '${environment_short}-fc-${controllerIdentity.name}'
  parent: controllerIdentity
  properties: {
    issuer: oidc_issuer_url
    subject: 'system:serviceaccount:kube-system:hsm-ingress-secret-creator'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}
