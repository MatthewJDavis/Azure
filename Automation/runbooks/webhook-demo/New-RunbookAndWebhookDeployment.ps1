<#
Deploy an AzureRM Automation Runbook with webhook
#>

$RunbookName = 'test-input-output'
$ResourceGroupName = 'automation'
$AutomationAccountName = 'matt-auto-acct'
$WebhookName = 'demo-webhook'


# Create the webhook
$hookParams = @{
  'AutomationAccountName' = $AutomationAccountName;
  'ResourceGroupName'     = $ResourceGroupName;
  'RunbookName'           = $RunbookName;
  'Name'                  = $WebhookName;
  'IsEnabled'             = $true;
  'ExpiryTime'            = (get-date).AddYears(5)
}

New-AzureRmAutomationWebhook @hookParams