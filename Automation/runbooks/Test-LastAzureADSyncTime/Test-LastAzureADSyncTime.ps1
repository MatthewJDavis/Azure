# Azure runbook running under the DSCLive automation account.


Import-Module -Name MSOnline
$creds = Get-AutomationPSCredential -Name 'AzureADConnectSyncAccount'
Connect-MsolService -Credential $creds


    <#
    .SYNOPSIS
        Check last sync time is within 2 hours 
    .DESCRIPTION
        Uses MSOL command to get the last sync time and check it is within two hours.
        If it isn't, output a message (this is where a slack hook or other alert can be triggered.
    #>
    $CompanyInformation = Get-MsolCompanyInformation

    if ((Get-Date).AddHours(-2) -gt $CompanyInformation.LastDirSyncTime) {
        # Send error message
        $Message = "Azure AD Connect`nNo AD to Azure sync for over 2 hours`nLast sync time was: $($CompanyInformation.LastDirSyncTime)`nPlease check sync service on the sync server."
        Write-Output $Message
    }
