#region VM resource group
$resourceGroupName = 'matt-dev-vm-rg'
$location = 'uksouth'
$project = 'Dev VM'

$rg = New-AzureRmResourceGroup -Name $resourceGRoupName -Location $location -Tag @{Project = $project}

#Get the current IP address for Network Security Group
$ip = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json'

$vmParams = @{
    'Name' = 'matt-dev-vm-deployment'
    'ResourceGroupName' = $resourceGroupName
    'TemplateFile' = 'azuredeploy.json'
    'TemplateParameterFile' = 'azuredeploy.parameters.json'
     'adminPassword' = (Read-Host -Prompt 'Enter Admin Password' -AsSecureString)
     'networkSecurityGroupAllowIP' = $ip.ip
}

#Create the VM from JSON templates
New-AzureRmResourceGroupDeployment @vmParams

#endregion


#region DSC config
$dscResourceGroup = "automation"
$dscStorageName = "autostor1232"
$location = "uksouth"
$vmrg = "matt-dev-vm-rg"
$vmName = "matt-dev-1"

$dscParams = @{
    'Version' = 2.21
     ResourceGroupName = $vmrg
     VMName = $vmName
     'ArchiveStorageAccountName' = $dscStorageName 
     'ArchiveResourceGroupName' = $dscResourceGroup
     'ArchiveBlobName' = 'New-DevVMConfig.ps1.zip'
     'AutoUpdate' = $true
     'ConfigurationName' = 'DevVM'
     'ArchiveContainerName' = 'dsc' 
}

#Publish the configuration script into user storage
#Publish-AzureRmVMDscConfiguration -ConfigurationPath .\New-DevVMConfig.ps1 -ResourceGroupName $dscResourceGroup -StorageAccountName $dscStorageName -ContainerName "dsc" -Force
#Set the VM to run the DSC configuration
Set-AzureRmVmDscExtension @dscParams

#endregion

#region chocolatey
Get-PackageSource -ProviderName chocolatey -Force


$installUrl = 'https://autostor1232.blob.core.windows.net/ps-scripts/Install-DevSoftware.ps1'

$chocoParams = @{
    'ResourceGroupName' = $resourceGroupName
    'VMName' = $vmName
    'Location' = $location
    'FileUri' = $installUrl
    'Run' = 'Install-DevSoftware.ps1' 
    'Name' = 'Install-Dev-Software'
}

Set-AzureRmVMCustomScriptExtension @chocoParams 

#endregion