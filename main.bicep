targetScope = 'subscription'

param tfRgName string
param tfSaName string
param tfCntrName string
param region string

resource terraformResourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: tfRgName 
  location: region
}

module tfRemoteBackend 'bicep_resources/terraform_remote_backend.bicep' = {
  name: 'tfBackendModule'
  scope: resourceGroup(tfRgName)
  params: {
    tfCntrName: tfCntrName
    tfSaName: tfSaName
  }
}

