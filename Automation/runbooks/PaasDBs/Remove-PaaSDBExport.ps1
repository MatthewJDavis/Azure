workflow Remove-GEMAppDBExport
{
    $connectionName = 'AzureRunAsConnection'
    try
    {
        # Get the connection 'AzureRunAsConnection '
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        'Logging in to Azure...'
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = 'Connection $connectionName not found.'
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
    InlineScript {
         # Delete the bacpac file in Azure storage
        $sastoken = Get-AutomationVariable -Name 'deleteSASToken'
        $container = 'database-backup'
        $blobName = 'restore.bacpac'    
        $storageAcctName = ''
        $context = New-AzureStorageContext -StorageAccountName $storageAcctName -SasToken $sastoken
        Remove-AzureStorageBlob -Context $context -Blob $blobName -Container $container
    }
}