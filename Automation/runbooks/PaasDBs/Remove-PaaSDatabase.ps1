workflow Remove-PaaSDatabase
{
# Use Azure automation to automate the removal of a PaaS database, reads the vars from the Assets store
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
    
    $sqlServer = Get-AutomationVariable -Name 'prodSQLServ'
    $resourceGroup = Get-AutomationVariable -Name 'resourceGroupName'
    $dbName = Get-AutomationVariable -Name 'restoreDBName'
    
    Remove-AzureRmSqlDatabase -DatabaseName $dbName -ServerName $sqlServer -ResourceGroupName $resourceGroup -Force 
}