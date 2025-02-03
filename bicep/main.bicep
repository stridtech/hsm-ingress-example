// TODO: We should consolidate to 1 main.bicep and just have parameters to differentiate
//       This file will try to follow that, so when we cover everything in main.bicep
//       we can just switch over.

// General settings
@description('Specifies the Azure location where the key vault should be created.')
param resourceGroupLocation string = resourceGroup().location

@allowed(['dev', 'tst', 'prd'])
@description('Specify environment short string')
param environment_short string = 'dev'

@description('Specifies if the ACR should be deployed.')
param deployACR bool = false

@description('Specifies if the AKV should be deployed.')
param deployAKV bool = false

@description('Specifies if the AKS should be deployed.')
param deployAKS bool = false

@description('Specified if we should install the ingress extension from marketplace')
param deployIngress bool = false

var namePrefix = '${environment_short}'

var akvName = '${namePrefix}-akv'
var aksName = '${namePrefix}-aks'

param salt string = take(uniqueString(guid(resourceGroup().id)), 5)

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

module akv './modules/akv.bicep' = if (deployAKV || deployAKS) {
  name: '${akvName}-01-module'
  params: {
    name: '${akvName}-01-${salt}'
    sshRSAPublicKey: sshRSAPublicKey
  }
}

module aks './modules/aks.bicep' = if (deployAKS) {
  name: '${aksName}-01-module'
  params: {
    clusterName: '${aksName}-01'
    dnsPrefix: '${aksName}-01'
    linuxAdminUsername: linuxAdminUsername
  }
}
module acr './modules/acr.bicep' = if (deployACR) {
  name: '${namePrefix}-acr-01-module'
  params: {
    name: 'stab${environment_short}acr01${salt}'
    resourceGroupLocation: resourceGroupLocation
  }
}

module acrRbac './modules/acr-role-assignment.bicep' = if (deployACR && deployAKS) {
  name: '${namePrefix}-aks-acr-rbac-01-module'
  params: {
    acrName: acr.outputs.name
    principalId: aks.outputs.aksPrincipalID
    roleIds: [ '7f951dda-4ed3-4680-a7ca-43fe172d538d' ] // ACR Pull, https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
  }
}

module AksAkvRbacIngress './modules/aks-akv-rbac-ingress.bicep' = if (deployAKS) {
  name: 'aks-akv-rbac-ingress'
  params: {
    keyVaultName: akv.outputs.name
    resourceGroupLocation: resourceGroupLocation
    oidc_issuer_url: aks.outputs.oidc_issuer_url
    environment_short: environment_short
  }
}

module AksAkvRbacController './modules/aks-akv-rbac-controller.bicep' = if (deployAKS) {
  name: 'aks-akv-rbac-controller'
  params: {
    keyVaultName: akv.outputs.name
    resourceGroupLocation: resourceGroupLocation
    oidc_issuer_url: aks.outputs.oidc_issuer_url
    environment_short: environment_short
  }
}

module aksExtensions './modules/aks-ingress.bicep' = if (deployIngress) {
  name: '${aksName}-extensions-01-module'
  params: {
    clusterName: '${aksName}-01'
    workloadIdentity: AksAkvRbacIngress.outputs.clientId
  }
}
