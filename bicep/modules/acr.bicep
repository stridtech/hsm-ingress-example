@description('Specifies the Azure location where the key vault should be created.')
param resourceGroupLocation string = resourceGroup().location

@description('Provide a globally unique name of your Azure Container Registry')
param name string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: resourceGroupLocation
  tags: {
    displayName: 'Container Registry'
    'container.registry': name
  }
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
output name string = acrResource.name
