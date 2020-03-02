# Azure Storage Account Template

This template will create an Azure storage account with the following configurable parameters:
- Location
- Storage Account Name
- Storage Tier
- Blob Encryption

By default LRS (Locally Redundant Storage) for the tier and Encryption are set.

To deploy the script using Azure PowerShell, you can run:

```ps1
New-AzureRmResourceGroupDeployment -Name test -ResourceGroupName rgName -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeployparameters.json -location uksouth -storageAccountName someuniqueacctname

```