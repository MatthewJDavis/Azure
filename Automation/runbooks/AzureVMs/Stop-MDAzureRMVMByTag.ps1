workflow Stop-MDAzureRMVMByTag {
  <#
        Stop a VM based on the powerOffTime tag value of the VM and the powerOffTime value of the parameter passed to the script.
        The time can be passed through via the schedule of the workbook or the default time of 23:00 will be used.
        This runs against a specified subscription passed in via the automation variable 'subscriptionName'
        Matt Davis 5th Aug 2017
    #>
  Param(
    [Parameter (Mandatory = $false)]
    [String] $powerOffTime	= "23:00"
  )

  $connectionName = "AzureRunAsConnection"
  $subName = Get-AutomationVariable -Name 'subscriptionName'
  try {
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
      -ServicePrincipal `
      -TenantId $servicePrincipalConnection.TenantId `
      -ApplicationId $servicePrincipalConnection.ApplicationId `
      -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    "Setting context to a specific subscription"   
    Set-AzureRmContext -SubscriptionName $subName         
  }
  catch {
    if (!$servicePrincipalConnection) {
      $errorMessage = "Connection $connectionName not found."
      throw $errorMessage
    }
    else {
      Write-Error -Message $_.Exception
      throw $_.Exception
    }
  } 
   
  # create an array for VMs where the power off time tag matches the PowerOffTime variable
  $vms = Get-AzureRmVM | Where-Object -FilterScript {$_.Tags.powerOffTime -eq $PowerOffTime} 
   
  foreach ($vm in $vms) {
    $name = $vm.Name
    "Stop command being sent to $name"
	   Stop-AzureRmVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force        
  } 
}