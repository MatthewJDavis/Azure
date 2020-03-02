<#  Reset a user's Azure mfa settings. This wipes the current settings so the user must provide them again next time the try to authenticate.
    User running the command from slack must be in the authorisedUsers hashtable.
    Requires the user's correct UPN in Azure otherwise will fail.
    https://api.slack.com/slash-commands for the format of how the data is sent to the webhook
    Percent encoding is used for the data see wikipedia for info: https://en.wikipedia.org/wiki/Percent-encoding
    Using Write-Output to outpupt information to Azure Automation runbook history to make searching who ran the command easier
#>
param
(
  [object] $WebhookData
)

#Hashtable of authorised users to run the command - add users and slack ID to this hashtable to allow them to reset Azure MFA
$authorisedUsers = @{
  'helpdesk.user1' = 'USlackID1'
  'helpdesk.user2' = 'USlackID2'
  'helpdesk.user3' = 'USlackID3'
  'helpdesk.user4' = 'USlackID4'
}

# MSOL module required and use the creds saved in Azure automation.
# Import module to Azure Automation https://docs.microsoft.com/en-us/azure/automation/automation-runbook-gallery#to-import-a-module-from-the-automation-module-gallery-with-the-azure-portal
Import-Module -name MSOnline
$creds = Get-AutomationPSCredential -Name 'Azure-AD-MFA-Reset'
Connect-MsolService -Credential $creds

if ($WebhookData) {

  # For testing JSON input in Azure portal  
  if ( -Not $WebhookData.RequestBody) {
    $WebhookData = (ConvertFrom-Json -InputObject $WebhookData)
  }

  # Get the data from the JSON Payload - slack uses & to define breaks in the data
  $slackData = $WebhookData.RequestBody.Split('&')

  # Slack sends the request body data with percent encoding so need to use replace method to transform the characters back to ascii

  # Get the UPN supplied from Slack
  $upnData = $slackData | Where-Object {$_ -like 'text*'}
  $upnSplit = $upnData.Split('=')
  $upnToReset = $upnSplit[1].Replace('%40', '@')
  Write-Output "UPNToReset = $upnToReset"

  # Get the user who requested the reset
  $userData = $slackData | Where-Object {$_ -like 'user_id*'}
  $userSplit = $userData.Split('=')
  $userWhoSentRequest = $userSplit[1]
  Write-Output "User who sent request = $userWhoSentRequest"

  # Response URL
  $uri = $slackData | Where-Object {$_ -like 'response_url*'}
  $uriSplit = $uri.Split('=')
  $responseUri = $uriSplit[1]
  $responseUri = $responseUri.Replace('%3A', ':')
  $responseUri = $responseUri.Replace('%2F', '/')
  Write-Output "Response URI = $responseUri"

  # Check that a full UPN has been sent
  if (-Not ($upnToReset.Contains('@') -and $upnToReset.Contains('.'))) {
    Write-Output 'Please provide a full UPN i.e. firstname.surname@domain.com'
    # No @ or . found in provided UPN so send message and break
    $json = "
      {
          'response_type': 'ephemeral',
          'text': 'Reset-Azure-MFA The provided UPN was not in the UPN format of firstname.surename@domain. UPN sent was: $upnToReset'
      }
      "
    Invoke-WebRequest -UseBasicParsing -Uri $responseUri -Method Post -Body $json
    break
  }

  # Check user who sent request is allowed to reset MFA
  if ($authorisedUsers.ContainsValue($userWhoSentRequest)) {
    if (Get-MsolUser -SearchString $upnToReset) {

      # Found user, reset MFA      
      Reset-MsolStrongAuthenticationMethodByUpn -UserPrincipalName $upnToReset

      # Check the MFA settings have been cleared for the user
      if ((Get-MsolUser -SearchString $upnToReset| Select-Object -ExpandProperty  StrongAuthenticationMethods | Measure-Object).Count -eq 0) {
        $json = "
          {
              'response_type': 'ephemeral',
              'text': 'Reset-Azure-MFA has reset Azure MFA for: $upnToReset'
          }
          "
      }
      else {
        # Problem with clearing MFA settings
        $json = "
          {
              'response_type': 'ephemeral',
              'text': 'Reset-Azure-MFA There was a problem with the reset of Azure MFA for: $upnToReset. Please try again.'
          }
          "
      }
      Invoke-WebRequest -UseBasicParsing -Uri $responseUri -Method Post -Body $json
    }
    else {
      # User not found via the supplied UPN
      $json = "
        {
            'response_type': 'ephemeral',
            'text': 'Reset-Azure-MFA could not find the UPN for: $upnToReset in Azure. Please check the UPN supplied'
        }
        "
      Invoke-WebRequest -UseBasicParsing -Uri $responseUri -Method Post -Body $json
    } 
  }
  else {
    $json = "
      {
        'response_type': 'ephemeral',
        'text': '$userWhoSentRequest Slack User ID is not authorised to reset Azure MFA. Please contact ask to have your Slack ID added.'
      }
      "
    Invoke-WebRequest -UseBasicParsing -Uri $responseUri -Method Post -Body $json
  }    
}