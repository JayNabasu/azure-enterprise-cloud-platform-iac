param location string
param synapseWorkspaceName string
param dataLakeStorageAccountName string

resource dataLakeStorage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: dataLakeStorageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true // Hierarchical Namespace for Azure Data Lake Gen2
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource defaultFilesystem 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${dataLakeStorage.name}/default/edw-raw'
}

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: 'https://${dataLakeStorage.name}.dfs.${environment().suffixes.storage}'
      filesystem: 'edw-raw'
    }
    sqlAdministratorLogin: 'synapseadmin'
    publicNetworkAccess: 'Disabled'
  }
}

output synapseId string = synapseWorkspace.id
output synapseEndpoint string = synapseWorkspace.properties.connectivityEndpoints.web
