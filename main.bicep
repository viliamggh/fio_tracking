targetScope = 'subscription'

param tfRgName string
param tfSaName string
param tfCntrName string

resource terraformResourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: tfRgName 
  location: 'weeu'
}

module tfRemoteBackend 'bicep_resources/terraform_remote_backend.bicep' {
  name: 'tfBackendModule'
  scope: resourceGroup(tfRgName)
  params: {
    tfCntrName: tfCntrName
    tfSaName: tfSaName
  }
}

