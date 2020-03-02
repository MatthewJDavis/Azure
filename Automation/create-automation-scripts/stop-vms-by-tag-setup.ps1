$pathToRunbook = 'C:\git\Azure\Automation\runbooks\Stop-MDAzureRMVMByTag.ps1'
$description = 'stop VMs by powerOffTime tag value'
$runbookType = 'PowerShellWorkflow'
$automationAccountName = 'matt-auto-acct'
$resourceGroupName = 'automation'

$runbookParams = @{
  'Path' = $pathToRunbook;
  'Description' = $description;
  'Type' = $runbookType
  'AutomationAccountName' = $automationAccountName;
  'ResourceGroupName' = $resourceGroupName;
  'Published' = $true 
}

Import-AzureRmAutomationRunbook @runbookParams

# create a new schedule
$scheduleName = 'Daily 2300 Power Off'
   
$timeZone = (Get-TimeZone).id
$startTime = get-date "23:00"
$dayInterval = 1
$scheduleName = $scheduleName
$scheduleDescription = 'Shutdown tagged VMs at 23:00'

$scheduleParams = @{
  'Name' = $scheduleName;
  'StartTime' = $startTime;
  'DayInterval' = $dayInterval;
  'Description' = $scheduleDescription;
  'TimeZone' = $timeZone;
  'AutomationAccountName' = $automationAccountName;
  'ResourceGroupName' = $resourceGroupName 
}

New-AzureRmAutomationSchedule @scheduleParams


# register the runbook with the schedule
$powerOffTime = '23:00'

$runSchdParams = @{
  RunbookName = 'Stop-MDAzureRMVMByTag';
  ScheduleName = $scheduleName;
  AutomationAccountName = $automationAccountName;
  ResourceGroupName = $resourceGroupName;
  'Parameters' = @{'PowerOffTime' = $powerOffTime}
}


Register-AzureRMAutomationScheduledRunbook @runSchdParams

