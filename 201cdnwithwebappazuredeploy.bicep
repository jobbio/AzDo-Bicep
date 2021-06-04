@description('Location for all resources.')
param location string = resourceGroup().location

var endpointName = 'RFendpoint-${uniqueString(resourceGroup().id)}'
var serverFarmName_var = 'RFServerFarm1'
var profileName_var = 'RFCdnProfile1'
var webAppName_var = 'web-${uniqueString(resourceGroup().id)}'

resource serverFarmName 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: serverFarmName_var 
  location: location
  tags: {
    displayName: serverFarmName_var
  }
  sku: {
    name: 'F1'
    capacity: 1
  }
  properties: {
    name: serverFarmName_var
  }
}

resource webAppName 'Microsoft.Web/sites@2019-08-01' = {
  name: webAppName_var
  location: location
  tags: {
    displayName: webAppName_var
  }
  properties: {
    name: webAppName_var
    serverFarmId: serverFarmName.id
  }
}

resource profileName 'Microsoft.Cdn/profiles@2020-04-15' = {
  name: profileName_var
  location: location
  tags: {
    displayName: profileName_var
  }
  sku: {
    name: 'Standard_Microsoft'
  }
  properties: {}
}

resource profileName_endpointName 'Microsoft.Cdn/profiles/endpoints@2020-04-15' = {
  parent: profileName
  name: '${endpointName}'
  location: location
  tags: {
    displayName: endpointName
  }
  properties: {
    originHostHeader: webAppName.properties.hostNames[0]
    isHttpAllowed: true
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'application/x-javascript'
      'text/javascript'
    ]
    isCompressionEnabled: true
    origins: [
      {
        name: 'origin1'
        properties: {
          hostName: webAppName.properties.hostNames[0]
        }
      }
    ]
  }
}

output hostName string = profileName_endpointName.properties.hostName
output originHostHeader string = profileName_endpointName.properties.originHostHeader
