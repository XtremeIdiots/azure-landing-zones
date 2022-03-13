targetScope = 'tenant'

module managementGroups 'br:acrxibicepprivate.azurecr.io/bicep/modules/managementgroups:V1' = {
  name: 'managementGroups'
  scope: tenant()
  params: {
    parTopLevelManagementGroupPrefix: 'alz'
  }
}

module customPolicyDefinitions 'br:acrxibicepprivate.azurecr.io/bicep/modules/custom-policy-definitions:V1' = {
  name: 'customPolicyDefinitions'
  scope: managementGroup('alz')
  params: {}
}

module customRoleDefinitions 'br:acrxibicepprivate.azurecr.io/bicep/modules/customroledefinitions:V1' = {
  name: 'customRoleDefinitions'
  scope: managementGroup('alz')
  params: {
    parAssignableScopeManagementGroupId: 'alz'
  }
}

module loggingResourceGroup 'br:acrxibicepprivate.azurecr.io/bicep/modules/resourcegroup:V1' = {
  name: 'loggingResourceGroup'
  scope: subscription('3f22e890-4c99-430e-a8dd-4ca7715db048')
  params: {
    parResourceGroupLocation: 'eastus'
    parResourceGroupName: 'rg-platform-logging'
  }
}

module platformLogging 'br:acrxibicepprivate.azurecr.io/bicep/modules/logging:V1' = {
  name: 'platformLogging'
  scope: resourceGroup('3f22e890-4c99-430e-a8dd-4ca7715db048', 'rg-platform-logging')
  params: {
    parLogAnalyticsWorkspaceName: 'log-platform-eastus-01'
    parLogAnalyticsWorkspaceRegion: 'eastus'
    parLogAnalyticsWorkspaceLogRetentionInDays: 64
    parAutomationAccountName: 'aa-platform-eastus-01'
    parAutomationAccountRegion: 'eastus'
  }
}
