targetScope = 'tenant'

module managementGroups 'br:acrxibicepprivate.azurecr.io/bicep/modules/managementgroups:V1' = {
  name: 'managementGroups'
  scope: tenant()
  params: {
    parTopLevelManagementGroupPrefix: 'alz'
  }
}

module customPolicyDefinitions 'br:acrxibicepprivate.azurecr.io/bicep/modules/custom-policy-definitions:V1' = {
  dependsOn: [
    managementGroups
  ]
  name: 'customPolicyDefinitions'
  scope: managementGroup('alz')
  params: {}
}

module customRoleDefinitions 'br:acrxibicepprivate.azurecr.io/bicep/modules/customroledefinitions:V1' = {
  dependsOn: [
    managementGroups
  ]
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
  dependsOn: [
    loggingResourceGroup
  ]
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

module subscriptionPlacementManagement 'br:acrxibicepprivate.azurecr.io/bicep/modules/subscriptionplacement:V1' = {
  dependsOn: [
    managementGroups
  ]
  name: 'subscriptionPlacementManagement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: [
      'b2b3132f-92b4-448c-adf3-c763056f8e94' //Mgmt-Core-PayAsYouGo
      '3f22e890-4c99-430e-a8dd-4ca7715db048' //sub-elz-platform-management
    ]
    parTargetManagementGroupId: managementGroups.outputs.outPlatformManagementMGName
  }
}

module subscriptionPlacementIdentity 'br:acrxibicepprivate.azurecr.io/bicep/modules/subscriptionplacement:V1' = {
  dependsOn: [
    subscriptionPlacementManagement
  ]
  name: 'subscriptionPlacementIdentity'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: [
      'ead28369-b42c-44bb-afbc-cc39c8b7f05a' //Mgmt-Identity-PayAsYouGo
    ]
    parTargetManagementGroupId: managementGroups.outputs.outPlatformIdentityMGName
  }
}

module subscriptionPlacementOnlineLandingZone 'br:acrxibicepprivate.azurecr.io/bicep/modules/subscriptionplacement:V1' = {
  dependsOn: [
    subscriptionPlacementIdentity
  ]
  name: 'subscriptionPlacementOnlineLandingZone'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: [
      '67f63261-8bcc-4a50-9341-d6e32884b382' //Portal-Dev-PayAsYouGo
      'edcc79a0-72ac-4d5a-b73d-fba2fdab332c' //Portal-Prd-PayAsYouGo
    ]
    parTargetManagementGroupId: managementGroups.outputs.outLandingZonesOnlineMGName
  }
}

module subscriptionPlacementSandbox 'br:acrxibicepprivate.azurecr.io/bicep/modules/subscriptionplacement:V1' = {
  dependsOn: [
    subscriptionPlacementOnlineLandingZone
  ]
  name: 'subscriptionPlacementSandbox'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: [
      'e8ae2a77-9893-4a9a-a2eb-98e68ad8b94e' //Sandbox-PayAsYouGo
    ]
    parTargetManagementGroupId: managementGroups.outputs.outSandboxMGName
  }
}

module customPolicyAssignments 'modules/policyAssignments/policyAssignments.bicep' = {
  dependsOn: [
    customPolicyDefinitions
  ]
  name: 'customPolicyAssignments'
  scope: managementGroup('alz')
  params: {
    parTopLevelManagementGroupPrefix: 'alz'
    parLogAnalyticsWorkspaceResourceID: platformLogging.outputs.outLogAnalyticsWorkspaceId
  }
}
