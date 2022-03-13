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
