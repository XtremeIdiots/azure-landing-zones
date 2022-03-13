# [<](./../README.md) Documentation

This documentation is to contain my notes on my journey of setting up Azure Landing Zones using the ALZ-Bicep approach. This may not end up anywhere.

## Getting Started

Initial documentation in [ALZ-Bicep](https://github.com/Azure/ALZ-Bicep) isn't *hugely* clear on how this is to be ingested or extended. Unlike the terraform implementations there is yet to be a large collection of implementation examples and it looks like there are some more enterprise or community features such as module sharing available.

I am not seeing any example repositories or projects showing example implementations.

The [Deployment Flow](https://github.com/Azure/ALZ-Bicep/wiki/DeploymentFlow) indicates the order of module execution and the [Pipelines example](https://github.com/Azure/ALZ-Bicep/wiki/PipelinesADO) backs that up.

### First Big Question

The examples all show execution from the local repository as in the modules are local in the repository and not using shared or remote modules.

e.g.

```yaml
  - task: AzureCLI@2
    displayName: Az CLI Deploy Management Groups
    name: create_mgs
    inputs:
      azureSubscription: $(ServiceConnectionName)
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az deployment tenant create \
        --template-file infra-as-code/bicep/modules/managementGroups/managementGroups.bicep \
        --parameters parTopLevelManagementGroupPrefix=$(ManagementGroupPrefix) parTopLevelManagementGroupDisplayName="$(TopLevelManagementGroupDisplayName)" \
        --location $(Location) \
        --name create_mgs-$(RunNumber)
```

My question initially would be: 'should I be forking or copying these modules into mine?' or 'is there a public repository for the modules?'

Some of the discussions look to be here:

* [ACR Deployment](https://github.com/Azure/ALZ-Bicep/wiki/ACRDeployment)
* [Create private registry for Bicep modules](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/private-module-registry?tabs=azure-powershell)
* [[Story] Bicep Registry](https://github.com/Azure/bicep/issues/2128)

So, for now it looks like I need to host these 'modules' myself in an Azure Container Registry and then consume them. Which looks to be the case as there are a couple of scripts included in the ALZ-Bicep repo.

Trying those scripts out though results in not all of the modules being deployed so have raised an [issue](https://github.com/Azure/ALZ-Bicep/issues/186).

Fundamentally it is not clear what the best practice is though so have also raised a [question](https://github.com/Azure/ALZ-Bicep/issues/187).
