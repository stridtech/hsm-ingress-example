@description('The AKS cluster name')
param clusterName string

@description('The workload identity used to access the AKV')
param workloadIdentity string

resource aks 'Microsoft.ContainerService/managedClusters@2024-03-02-preview' existing = {
  name: clusterName
}

resource ingressExtension 'Microsoft.KubernetesConfiguration/extensions@2023-05-01' = {
  name: 'ingress-extension'
  identity: {
    type: 'SystemAssigned'
  }
  scope: aks
  plan: {
    name: 'basic'
    product: 'ingress-nginx-hsm'
    publisher: 'stridtech'
  }
  properties: {
    extensionType: 'tech.strid.ingress-nginx-hsm'
    autoUpgradeMinorVersion: true
    configurationSettings: {
      workloadIdentity: workloadIdentity
      kubernetesNamespace: 'ingress-nginx'
      controllerReplicaCount: '3' // Default is 1, but we want to have HA
      defaultBackendReplicaCount: '1'
    }
  }
}
