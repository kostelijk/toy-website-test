# Exercise description: https://docs.microsoft.com/en-us/learn/modules/test-bicep-code-using-github-actions/4-exercise-set-up-environment?pivots=powershell


#Set Variables
$githubOrganizationName = 'kostelijk'
$githubRepositoryName = 'toy-website-test'

#Create workload identity. You create two federated credentials to prepare for an exercise later in this module
$applicationRegistration = New-AzADApplication -DisplayName 'toy-website-test'
New-AzADAppFederatedCredential `
   -Name 'toy-website-test' `
   -ApplicationObjectId $applicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):environment:Website"

New-AzADAppFederatedCredential `
   -Name 'toy-website-test-branch' `
   -ApplicationObjectId $applicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):ref:refs/heads/main"

#Create a resource group in Azure and grant the workload identity access
$resourceGroup = New-AzResourceGroup -Name ToyWebsiteTest -Location westeurope

New-AzADServicePrincipal -AppId $($applicationRegistration.AppId)
New-AzRoleAssignment `
   -ApplicationId $($applicationRegistration.AppId) `
   -RoleDefinitionName Contributor `
   -Scope $($resourceGroup.ResourceId)

#Prepare GitHub secrets. The values shown in the output should be created as GitHub Secrets 
$azureContext = Get-AzContext
Write-Host "AZURE_CLIENT_ID: $($applicationRegistration.AppId)"
Write-Host "AZURE_TENANT_ID: $($azureContext.Tenant.Id)"
Write-Host "AZURE_SUBSCRIPTION_ID: $($azureContext.Subscription.Id)"
