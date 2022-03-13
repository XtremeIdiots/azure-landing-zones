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

### Proceeding Anyway

Trying those scripts out though results in not all of the modules being deployed so have raised an [issue](https://github.com/Azure/ALZ-Bicep/issues/186). Fundamentally it is not clear what the best practice is though so have also raised a [question](https://github.com/Azure/ALZ-Bicep/issues/187).

In any case for the script that was provided I had to modify to: <https://github.com/frasermolyneux/ALZ-Bicep/blob/main/docs/scripts/createRGandcallBicep.ps1> to allow for publishing of all modules and to be able to specify the name of the ACR instance.

## Next Step - Deploy some resources

So - first steps for me are to try and do this locally, I already have an account that has the prerequisites.

Unlike the examples that are provided in the ALZ-Bicep repo I can't see a way to reference the module directly as a template from the ACR. That is in the examples `az deployment` is called referencing the module .bicep file, once that module is published then it can't be referenced in the same way. As such a wrapper is needed.

Following on from the `deployment model` documentation I will create a .bicep file for each stage in this repo which will call the various remote modules.

As such I have created [bicep/management.bicep](/bicep/management.bicep) that will deploy the:

* Management Groups
* Custom RBAC Role Definitions

also a local script to run this: [manual/localDeploy.azcli](/manual/localDeploy.azcli)

There is a 'weirdness' or potential anti-pattern here as in the examples there is the ability to breakdown the pipeline with a task per deployment whereas this is 'grouping' aspects together. Unsure if this is an issue yet though.

## Next Step - Policies

First stage of this is to add the custom policy definitions - this is a straightforward add. We then need to dive into the assignments, There are some default enterprise scale policies that I do not want etc.

Didn't clock that the assignments aren't until further down in the process, as such moving on to...

## Next Steps - Logging

This is a straightforward module add. It is highlighting though the need to have a parameters file for this management.bicep I have. Also raises questions on if I am putting too much into this file and losing the modular approach.

## Next Steps - Core Hub Network

Skipping this one as the XtremeIdiots platform is PaaS only and low/minimal cost.

## Next Steps - Role Assignments

The ALZ-Bicep resources contain several modules here, one for Management Groups, Subscriptions and then a 'Many' for each.

Skipping this one temporarily.

## Next Steps - Subscription Placement

The implementation for this one was educational as far as referencing outputs from previously run modules etc. Very simple and the intellisense was helpful - easier than terraform for sure.

I did also learn the need for dependsOn as there were conflicting deployments etc, so have gone through and added them in. The ALZ-Bicep example was lacking in that it only shows one usage here.

I don't like the naming of the parTargetManagementGroupId param also as it's not the ID but the name it is looking for. Oh well.

Additionally, this is probably where I would want to start splitting stuff out into more logical deployment phases.

## Next Steps - Policy Assignments

So looking at this the ALZ-Bicep documentation under the deployment flow has an alzDefaults 'module' which is not so straightforward to understand. There are some odd bits in there, understandable things but odd when reading.

So what am I trying to accomplish? at present I am really just looking for the logging/diagnostic policies - my thoughts then are to essentially implement my own version of the `alzDefaults` module.
