targetScope = 'tenant'

module managementGroups 'br:acrxibicepprivate.azurecr.io/bicep/modules/managementgroups:V1' = {
  name: 'managementGroups'
  scope: tenant()
  params: {
    parTopLevelManagementGroupPrefix: 'alz'
  }
}

module customRoleDefinitions 'br:acrxibicepprivate.azurecr.io/bicep/modules/customroledefinitions:V1' = {
  name: 'customRoleDefinitions'
  scope: managementGroup('alz')
  params: {
    parAssignableScopeManagementGroupId: 'alz'
  }
}
