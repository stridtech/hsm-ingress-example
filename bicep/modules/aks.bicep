@description('The name of the Managed Cluster resource.')
param clusterName string = 'dev-aks-01'

@description('Specifies the Azure location where the key vault should be created.')
param resourceGroupLocation string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 1

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_b4als_v2'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

resource aks 'Microsoft.ContainerService/managedClusters@2024-03-02-preview' = {
  name: clusterName
  location: resourceGroupLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'enabled'
    dnsPrefix: dnsPrefix
    ingressProfile: {
      webAppRouting: {
         enabled: false
      }
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      networkPluginMode: 'overlay'
      loadBalancerSku: 'standard'
    }
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

var aksPrincipalID = aks.properties.identityProfile.kubeletidentity.objectId

output controlPlaneFQDN string = aks.properties.fqdn
output clusterName string = aks.name
output aksPrincipalID string = aksPrincipalID
output oidc_issuer_url string = aks.properties.oidcIssuerProfile.issuerURL
