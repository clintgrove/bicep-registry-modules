targetScope = 'subscription'

metadata name = 'Using large parameter set'
metadata description = 'This instance deploys the module with most of its features enabled.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-eventgrid.systemtopics-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'egstmax'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    managedIdentityName: 'dep-${namePrefix}-msi-${serviceShort}'
    storageAccountName: 'dep${namePrefix}sa${serviceShort}'
    storageQueueName: 'dep${namePrefix}sq${serviceShort}'
    location: resourceLocation
  }
}

// Diagnostics
// ===========
module diagnosticDependencies '../../../../../../../utilities/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep${namePrefix}diasa${serviceShort}01'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}-law-${serviceShort}'
    eventHubNamespaceEventHubName: 'dep-${namePrefix}-evh-${serviceShort}'
    eventHubNamespaceName: 'dep-${namePrefix}-evhns-${serviceShort}'
    location: resourceLocation
  }
}

// ============== //
// Test Execution //
// ============== //
@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      name: '${namePrefix}${serviceShort}001'
      source: nestedDependencies.outputs.storageAccountResourceId
      topicType: 'Microsoft.Storage.StorageAccounts'
      location: resourceLocation
      eventSubscriptions: [
        {
          name: '${namePrefix}${serviceShort}001'
          expirationTimeUtc: '2099-01-01T11:00:21.715Z'
          filter: {
            isSubjectCaseSensitive: false
            enableAdvancedFilteringOnArrays: true
          }
          retryPolicy: {
            maxDeliveryAttempts: 10
            eventTimeToLiveInMinutes: 120
          }
          eventDeliverySchema: 'CloudEventSchemaV1_0'
          destination: {
            endpointType: 'StorageQueue'
            properties: {
              resourceId: nestedDependencies.outputs.storageAccountResourceId
              queueMessageTimeToLiveInSeconds: 86400
              queueName: nestedDependencies.outputs.queueName
            }
          }
        }
      ]
      diagnosticSettings: [
        {
          name: 'customSetting'
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
          eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
          storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
          workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
        }
      ]
      lock: {
        kind: 'CanNotDelete'
        name: 'myCustomLockName'
      }
      managedIdentities: {
        systemAssigned: true
      }
      roleAssignments: [
        {
          name: 'c9beca28-efcf-4d1d-99aa-8f334484a2c2'
          roleDefinitionIdOrName: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
          principalId: nestedDependencies.outputs.managedIdentityPrincipalId
          principalType: 'ServicePrincipal'
        }
        {
          name: guid('Custom seed ${namePrefix}${serviceShort}')
          roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
          principalId: nestedDependencies.outputs.managedIdentityPrincipalId
          principalType: 'ServicePrincipal'
        }
        {
          roleDefinitionIdOrName: subscriptionResourceId(
            'Microsoft.Authorization/roleDefinitions',
            'acdd72a7-3385-48ef-bd42-f606fba81ae7'
          )
          principalId: nestedDependencies.outputs.managedIdentityPrincipalId
          principalType: 'ServicePrincipal'
        }
      ]
      externalResourceRoleAssignments: [
        {
          resourceId: nestedDependencies.outputs.storageAccountResourceId
          roleDefinitionId: '974c5e8b-45b9-4653-ba55-5f855dd0fb88' // Storage Queue Data Contributor
          description: 'Allow Event Grid System Topic to write to storage queue'
        }
        {
          resourceId: nestedDependencies.outputs.storageAccountResourceId
          roleDefinitionId: 'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a' // Storage Queue Data Message Sender
          description: 'Allow Event Grid System Topic to send messages to storage queue'
        }
      ]
      tags: {
        'hidden-title': 'This is visible in the resource name'
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
    }
  }
]
