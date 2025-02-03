@description('Specifies the Azure location where the key vault should be created.')
param resourceGroupLocation string = resourceGroup().location

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets. If not provided no rbac will be set')
param rbacObject string = 'empty'

@description('Specifies the name of the AKV')
param name string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: resourceGroupLocation
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'premium'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    createMode: 'default'
    accessPolicies:[]
    enableRbacAuthorization: true

    enableSoftDelete: true
    // softDeleteRetentionInDays: 1
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
  }
}

resource keyVaultRsaKey 'Microsoft.KeyVault/vaults/keys@2023-07-01' = {
  name: 'testrsakey-${uniqueString(resourceGroup().id)}'
  parent: keyVault
  properties: {
    kty: 'RSA'
    keySize: 2048
    keyOps: [
      'decrypt'
      'encrypt'
      'sign'
      'verify'
    ]
    attributes: {
      exportable: false
    }
  }
}

@description('This is the built-in Key Vault Crypto Officer role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource keyVaultCryptoOfficerRoleRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
}

@description('This is the built-in Key Vault Crypto Officer role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-contributor')
resource keyVaultContributorRoleRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'f25e0fa2-a7c8-4377-a976-54943a77a395'
}

resource keyVaultCryptoRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (rbacObject != 'empty') {
  scope: keyVault
  name: guid(keyVault.id, rbacObject, keyVaultCryptoOfficerRoleRoleDefinition.id)
  properties: {
    roleDefinitionId: keyVaultCryptoOfficerRoleRoleDefinition.id
    principalId: rbacObject
    principalType: 'User'
  }
}

resource kvContributorRolerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (rbacObject != 'empty') {
  scope: keyVault
  name: guid(keyVault.id, rbacObject, keyVaultContributorRoleRoleDefinition.id)
  properties: {
    roleDefinitionId: keyVaultContributorRoleRoleDefinition.id
    principalId: rbacObject
    principalType: 'User'
  }
}


output location string = resourceGroupLocation
output name string = keyVault.name
output resourceGroupName string = resourceGroup().name
output resourceId string = keyVault.id
