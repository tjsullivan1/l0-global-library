param virtualNetworkName string
param location string = resourceGroup().location

param addressPrefix string = '10.0.0.0/16'

param subnets array = [
  {
    name: 'sub1'
    nsg_id: ''
    subnetPrefix: '10.0.0.0/24'
    PEpol: 'Enabled'
    PLSpol: 'Enabled'
    natgw_id: ''
  }
]

param tags object = {}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        natGateway: (!empty(subnet.natgw_id)) ? {
          id: subnet.natgw_id
        } : null
        networkSecurityGroup: (!empty(subnet.nsg_id)) ? { 
          id: subnet.nsg_id 
        } : null
        privateEndpointNetworkPolicies: subnet.PEpol
        privateLinkServiceNetworkPolicies: subnet.PLSpol
      }
    }]
  }
  tags: tags
}

output vnet_id string = virtualNetwork.id
output subnets array = [for (subnet, i) in subnets: {
  subnet_name: virtualNetwork.properties.subnets[i].name 
  subnet_id: virtualNetwork.properties.subnets[i].id 
  subnet_prefix: virtualNetwork.properties.subnets[i].properties.addressPrefix
}]
