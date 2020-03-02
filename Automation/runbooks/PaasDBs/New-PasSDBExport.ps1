workflow New-PaaSDBExport
{
# Export an Azure PaaS database bacpac file to Azure blob storage using Azure automation

#region Get the connection 'AzureRunAsConnection
    $connectionName = 'AzureRunAsConnection'
    try
    {
        $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

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
#endregion 

    $sasConnection = Get-AutomationVariable -Name 'writeSASToken'
    $sqlCredential = Get-AutomationPSCredential -Name 'sqladmin'
    $databaseName = Get-AutomationVariable -Name 'restoreDBName'
    $sqlSrv = Get-AutomationVariable -Name 'prodSQLServ'
    $rgName = Get-AutomationVariable -Name 'resourceGroupName'
    $storAcctEndPoint = Get-AzureAutomationVariable -Name 'commonStorAcctEndPoint'
    $uri = $storAcctEndPoint + 'database-backup/' + 'restore.bacpac'

    New-AzureRmSqlDatabaseExport -DatabaseName $databaseName -ServerName $sqlSrv -StorageKeyType 'SharedAccessKey' -StorageKey $sasConnection -StorageUri $uri -ResourceGroupName $rgName -AuthenticationType 'Sql' -AdministratorLogin $sqlCredential.UserName -AdministratorLoginPassword $sqlCredential.Password
}

