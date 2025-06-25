module factory 'br/public:avm/res/data-factory/factory:0.10.0' = {
  params: {
    name: 'bossfactory3'
    location: 'ukwest'
    privateEndpoints: [
      {
        name: 'pe2facfromboss4'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '/subscriptions/6d0a0c1f-6739-473b-962f-01f793ed5368/resourceGroups/networking/providers/Microsoft.Network/privateDnsZones/privatelink.datafactory.azure.net'
            }
          ]
        }

        resourceGroupResourceId: '/subscriptions/6d0a0c1f-6739-473b-962f-01f793ed5368/resourceGroups/networking'
        service: 'dataFactory'
        subnetResourceId: '/subscriptions/6d0a0c1f-6739-473b-962f-01f793ed5368/resourceGroups/virtual-machines/providers/Microsoft.Network/virtualNetworks/fordbxvm-vnet/subnets/default'
      }
    ]
    managedPrivateEndpoints: [
      {
        fqdns: [
          'fiftysixstg1.blob.core.windows.net'
        ]
        groupId: 'blob'
        name: 'pe2facfromboss5'
        privateLinkResourceId: '/subscriptions/6d0a0c1f-6739-473b-962f-01f793ed5368/resourceGroups/storageaccounts/providers/Microsoft.Storage/storageAccounts/fiftysixstg1'
      }
    ]
    managedVirtualNetworkName: 'default'
    integrationRuntimes: [
      {
        managedVirtualNetworkName: 'default'
        name: 'IRvnetManaged'
        type: 'Managed'
        typeProperties: {
          computeProperties: {
            location: 'AutoResolve'
          }
        }
      }
    ]
  }
}
