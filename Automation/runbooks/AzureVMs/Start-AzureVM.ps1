workflow Start-AzureVM
{
    <# 
        Workflow that runs through the subscription and will start a VM based on the StartTime value compated to powerOn tag value of the VM.
        The tag time can be passed through via the schedule of the workbook or the default time of 09:00 will be used.
        There is a check for the weekend, most VMs won't need to be started at the weekend. If it does a tag added called weekendStartUp
        with the value true will start the VM at the weekend
        Matt Davis 9th Aug 2016
    #>
	Param(
    	[Parameter (Mandatory = $False)]
   		[String] $StartTime	= "09:00"
	)
   
   $day = (Get-Date).DayOfWeek   
   $connectionName = "AzureRunAsConnection"
   $subName = Get-AutomationVariable -Name 'SubscriptionName'

   try
   {
      # Get the connection "AzureRunAsConnection "
      $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

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
       if (!$servicePrincipalConnection)
       {
           $errorMessage = "Connection $connectionName not found."
           throw $errorMessage
       } else{
           Write-Error -Message $_.Exception
           throw $_.Exception
       }
   } 

   if($day.DayOfWeek -eq 'Saturday' -or $day.DayOfWeek -eq 'Sunday')
   {
	   $vms = Get-AzureRmVM | Where-Object -FilterScript {$_.Tags.powerOn -eq $StartTime -and $_.Tags.weekendStartUp -eq "true"} 	   
   } 
   else
   {
        $vms = Get-AzureRmVM | Where-Object -FilterScript {$_.Tags.powerOn -eq $StartTime}     
   } 
	
  
	foreach($vm in $vms)
	{
		Start-AzureRmVM -Name $vm.Name -resourceGroupName $vm.resourceGroupName
	}   
}