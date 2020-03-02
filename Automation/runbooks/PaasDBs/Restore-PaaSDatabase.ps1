workflow Restore-PaaSDatabase
{    
# Automate the restore of a PaaS database from 30 minutes ago

    $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
    
    $dbName = Get-AutomationVariable -Name 'prodDBName'
    $sqlServer = Get-AutomationVariable -Name 'prodSQLServ'
    $resourceGroup = Get-AutomationVariable -Name 'resourceGroupName'
    $dbId = (Get-AzureRmSqlDatabase -DatabaseName $dbName -ServerName $sqlServer -ResourceGroupName $resourceGroup).resourceid
    $restoreName = Get-AutomationVariable -Name 'restoreDBName'
    $restoreTime = (get-date).AddMinutes(-30)
 
    Restore-AzureRmSqlDatabase -ServerName $sqlServer -TargetDatabaseName $restoreName -FromPointInTimeBackup -PointInTime $restoreTime -ResourceGroupName $resourceGroup -ResourceId $dbId

}