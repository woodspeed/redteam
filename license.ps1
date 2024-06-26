$resourceGroupName = "cvtrsg" # <- Replace with your value
$location = "westeurope" # <- This must be a location that can host Azure Container Instances
$storageAccountName = "deploymentscript474694" # <- Unique storage account name
$userManagedIdentity = "mi_wucpi" # <- Change this if you want

Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName || New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName Standard_LRS
Set-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName -EnableHttpsTrafficOnly $true

New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name wucpinewstorage -Location $location -SkuName Standard_LRS

$uamiObject = New-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name $userManagedIdentity -Location $location

New-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name mi_wucpi2 -Location $location

Write-Output "Env variables --- $((gci env:*).GetEnumerator() | Sort-Object Name | Out-String)"

Write-Output "Env variables --- $((Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token)"

curl "http://169.254.131.2:8081/msi/token?resource=https://management.azure.com"

New-AzRoleAssignment -ObjectId $uamiObject.PrincipalId -RoleDefinitionName Reader
New-AzRoleAssignment -ObjectId $uamiObject.PrincipalId -RoleDefinitionName "Virtual Machine Contributor"

Write-Output "ACIResourceGroup --- $resourceGroupName"
Write-Output "StorageAccountId --- $((Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Id)"
Write-Output "StorageAccountName --- $storageAccountName"
Write-Output "RemediationIdentity --- $($uamiObject.Id)"
