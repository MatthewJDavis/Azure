#To get resource groups run> Get-AzureRmResourceGroup 
#Use raw files fron github
$deployname = "storageAcctTemplate"
$rgname = "research-resource-group-Matt"
$TemplateUri = "https://raw.githubusercontent.com/MatthewJDavis/PowerShell/azure-vms/Azure/virtual-machines/vm-template-win-server2012R2/azuredeploy.json"
$ResTemplateParameterUri = "https://raw.githubusercontent.com/MatthewJDavis/PowerShell/azure-vms/Azure/virtual-machines/vm-win-server2012R2-res/vm-ws-2012r2-parameters-res.json"





New-AzureRmResourceGroupDeployment -Name Win-ser-res -ResourceGroupName $rgname -TemplateUri $TemplateUri -TemplateParameterUri $ResTemplateParameterUri -Verbose

New-AzureRmResourceGroupDeployment -Name Win-ser-res -ResourceGroupName $rgname -TemplateFile C:\Git\PowerShell\Azure\virtual-machines\vm-win-server2012R2-template\azuredeploy.json -TemplateParameterFile C:\Git\PowerShell\Azure\virtual-machines\vm-win-server2012R2-res\vm-ws-2012r2-parameters-res.json -Verbose
