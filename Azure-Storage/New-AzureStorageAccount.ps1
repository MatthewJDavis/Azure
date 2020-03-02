#To get resource groups run> Get-AzureRmResourceGroup 
#Use raw files fron github
$deployname = "storageAcctTemplate"
$rgname = "research-resource-group-Matt"
$TemplateUri = "https://raw.githubusercontent.com/MatthewJDavis/PowerShell/azure-storage-accounts/Azure/storage-account/storage-account-template/azuredeploy.json"
$ResTemplateParameterUri = "https://raw.githubusercontent.com/MatthewJDavis/PowerShell/azure-storage-accounts/Azure/storage-account/storage-account-research/storage-acct-parameters-res.json"
$TestTemplateParameterUri = "https://raw.githubusercontent.com/MatthewJDavis/PowerShell/azure-storage-accounts/Azure/storage-account/storage-account-test/storage-acct-parameters-test.json"
$DevTemplateParameterUri = "https://raw.githubusercontent.com/MatthewJDavis/PowerShell/azure-storage-accounts/Azure/storage-account/storage-account-test/storage-acct-parameters-dev.json"


New-AzureRmResourceGroupDeployment -Name $deployname -ResourceGroupName $rgname -TemplateUri $TemplateUri -TemplateParameterUri $TestTemplateParameterUri -Verbose




