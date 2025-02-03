using '../main.bicep'

param resourceGroupLocation = 'swedencentral'
param environment_short = 'dev'

param deployACR = true
param deployAKS = true
param deployAKV = true
