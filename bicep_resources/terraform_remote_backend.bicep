targetScope = 'resourceGroup'

param tfSaName string
param tfCntrName string

// param location string = subscription().location
param storageAccountType string = 'Standard_LRS'
param minTlsVersion string = 'TLS1_2'
param stKind string = 'StorageV2'

@description('')
resource terraformStorageAcc 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: tfSaName
  kind: stKind
  location: resourceGroup().location
  properties:{
    minimumTlsVersion: minTlsVersion
    isHnsEnabled: true
    allowBlobPublicAccess: false
    accessTier: 'Hot'
  }
  sku: {
    name: storageAccountType
  }
}


resource tfContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${tfSaName}/default/${tfCntrName}'
  properties:{
    publicAccess:'None'
  }
}

