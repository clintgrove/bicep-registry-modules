param location string = 'eastus'
param workspaceName string = 'db1kvworkspc'
param keyVaultName string = 'dbx1KeyVgroove2'
param keyName string = 'databricksKey'
param skuName string = 'premium' // Can be standard or premium
param resourceGroupName string = 'dbx-onekeyvault'
var managedResourceGroupName = 'dbx-onekeyvault-managed'
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
    name: keyName
    properties: {
      kty: 'RSA' // RSA key type
      keySize: 2048
    }
  }
}

resource databricksWorkspace 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: workspaceName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
    encryption: {
      entities: {
        managedDisk: {
          keySource: 'Microsoft.Keyvault'
          keyVaultProperties: {
            keyVaultUri: keyVault.properties.vaultUri
            keyName: keyVault::key.name
            keyVersion: last(split(keyVault::key.properties.keyUriWithVersion, '/')) // key.properties.keyUriWithVersion // Use the key version from the key resource
          }
        }
        managedServices: {
          keySource: 'Microsoft.Keyvault'
          keyVaultProperties: {
            keyName: keyVault::key.name
            keyVaultUri: keyVault.properties.vaultUri
            keyVersion: last(split(keyVault::key.properties.keyUriWithVersion, '/'))
          }
        }
      }
    }
  }
}

output keyVaultUri string = keyVault.properties.vaultUri
output databricksWorkspaceId string = databricksWorkspace.id
