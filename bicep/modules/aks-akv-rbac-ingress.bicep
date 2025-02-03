@description('Name of the KeyVault for retrieval')
param keyVaultName string

param resourceGroupLocation string

param oidc_issuer_url string

param environment_short string

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

@description('This is the built-in Key Vault Crypto User role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-crypto-user')
resource keyVaultCryptoOfficerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '12338af0-0e69-4776-bea7-57ae8d297424'
}

@description('This is the built-in Key Vault Crypto Officer role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-contributor')
resource keyVaultContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'f25e0fa2-a7c8-4377-a976-54943a77a395'
}

resource ingressIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${environment_short}-uai-ingress'
  location: resourceGroupLocation
}

resource keyVaultCryptoRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, ingressIdentity.name, keyVaultCryptoOfficerRoleDefinition.id)
  properties: {
    roleDefinitionId: keyVaultCryptoOfficerRoleDefinition.id
    principalId: ingressIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource kvContributorRolerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, ingressIdentity.name, keyVaultContributorRoleDefinition.id)
  properties: {
    roleDefinitionId: keyVaultContributorRoleDefinition.id
    principalId: ingressIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource federatedCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: '${environment_short}-fc-${ingressIdentity.name}'
  parent: ingressIdentity
  properties: {
    issuer: oidc_issuer_url
    subject: 'system:serviceaccount:ingress-nginx:ingress-extension-ingress-nginx-hsm'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

output clientId string = ingressIdentity.properties.clientId
