param location string = 'eastus'
param workspaceName string = 'db1kvworkspc7'
param keyVaultName string = 'dbx1KeyVgroove7'
param keyVaultNameDisk string = 'dbx1KeyDISKVgroove7'
param storageAccountNamevar string = 'doghgrdbx7'
var managedResourceGroupName = 'dbx-onekeyvault-managed7'
var trimmedMRGName = substring(managedResourceGroupName, 0, min(length(managedResourceGroupName), 90))
var managedResourceGroupId = '${subscription().id}/resourceGroups/${trimmedMRGName}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enablePurgeProtection: true // Required for encryption to work
    softDeleteRetentionInDays: 7
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enabledForDeployment: true
    enableRbacAuthorization: true
    accessPolicies: []
  }

  resource key 'keys@2022-07-01' = {
    name: 'dbxkey'
    properties: {
      kty: 'RSA' // RSA key type
      keySize: 2048
    }
  }
}
resource keyVaultDisk 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultNameDisk
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enablePurgeProtection: true // Required for encryption to work
    softDeleteRetentionInDays: 7
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enabledForDeployment: true
    enableRbacAuthorization: true
    accessPolicies: []
  }

  resource key 'keys@2022-07-01' = {
    name: 'dbxkeyDisk'
    properties: {
      kty: 'RSA' // RSA key type
      keySize: 2048
    }
  }
}

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    name: '${uniqueString(deployment().name, 'uksouth')}-test-dog-${iteration}'
    params: {
      name: workspaceName
      location: resourceGroup().location
      customerManagedKey: {
        keyName: keyVault::key.name
        keyVaultResourceId: keyVault.id
      }
      customerManagedKeyManagedDisk: {
        keyName: keyVault::key.name //keyVaultDisk::key.name
        keyVaultResourceId: keyVault.id //keyVaultDisk.id
        autoRotationEnabled: false
      }
      storageAccountName: storageAccountNamevar
      storageAccountSkuName: 'Standard_ZRS'
      skuName: 'premium'
      // Please do not change the name of the managed resource group as the CI's removal logic relies on it
      managedResourceGroupResourceId: managedResourceGroupId //'${subscription().id}/resourceGroups/rg-${resourceGroupName}-managed'
    }
  }
]
