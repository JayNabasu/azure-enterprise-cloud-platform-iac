@description('Environment prefix (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environmentName string = 'prod'

@description('Primary Azure region for enterprise deployment')
param location string = resourceGroup().location

@description('Base enterprise workload identifier')
param workloadName string = 'nnpc-energy'

// Unique resource naming tokens
var prefix = '${workloadName}-${environmentName}'
var locationToken = location

// 1. Core Enterprise Networking & Security
module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    vnetName: '${prefix}-vnet'
    addressPrefix: '10.240.0.0/16'
  }
}

// 2. Azure Key Vault (Zero Trust RBAC)
module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvaultDeployment'
  params: {
    location: location
    keyVaultName: '${replace(prefix, '-', '')}kv'
    subnetId: network.outputs.privateEndpointsSubnetId
  }
}

// 3. Azure Cache for Managed Redis
module redis 'modules/redis.bicep' = {
  name: 'redisDeployment'
  params: {
    location: location
    redisName: '${prefix}-redis'
    subnetId: network.outputs.redisSubnetId
  }
}

// 4. Azure App Service (Enterprise Subsidiary Web Platform)
module appservice 'modules/appservice.bicep' = {
  name: 'appServiceDeployment'
  params: {
    location: location
    appServicePlanName: '${prefix}-plan'
    webAppName: '${prefix}-app'
    subnetId: network.outputs.appServiceSubnetId
    redisHostName: redis.outputs.hostName
    keyVaultUri: keyvault.outputs.keyVaultUri
  }
}

// 5. Azure Functions (Event-Driven Telemetry Ingestion)
module functions 'modules/functions.bicep' = {
  name: 'functionsDeployment'
  params: {
    location: location
    functionAppName: '${prefix}-func'
    storageAccountName: '${replace(prefix, '-', '')}fnstor'
    subnetId: network.outputs.functionsSubnetId
  }
}

// 6. Azure Synapse Analytics & Data Lake Gen2 (Enterprise Data Warehouse)
module synapse 'modules/synapse.bicep' = {
  name: 'synapseDeployment'
  params: {
    location: location
    synapseWorkspaceName: '${prefix}-synapse'
    dataLakeStorageAccountName: '${replace(prefix, '-', '')}adls'
  }
}

output webAppEndpoint string = appservice.outputs.webAppDefaultHostName
output redisHostName string = redis.outputs.hostName
output synapseWorkspaceEndpoint string = synapse.outputs.synapseEndpoint
