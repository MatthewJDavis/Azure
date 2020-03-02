Param
(
    [object]$WebhookData
)

if ($WebhookData) {

    # If section for testing providing webhook data via the Azure portal
    if (-Not $WebhookData.RequestBody) {
        Write-Output 'No request body from test pane'
        $WebhookData = (ConvertFrom-JSON -InputObject $WebhookData)

        Write-Output "WebhookData = $WebhookData"
        $data = (ConvertFrom-JSON -InputObject $WebhookData.RequestBody)
        Write-Output "Service = $($data.Message)"

        Return
    }
    $request = (ConvertFrom-JSON -InputObject $WebhookData.RequestBody)
} Else {
    Write-Output 'No data received'
}


function New-MDSlackMessage {
    <#
    .SYNOPSIS
        Send a message to Slack
    .DESCRIPTION
        Send a JSON payload to slack consisting of a text message
    .EXAMPLE
        New-MDSlackMessage -URI $SlackHook -Message 'hi'
        
        Send the message 'hi' to slack
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        Requires a Slack app https://api.slack.com/apps and the URI of the slack hook and a valid bearer token passed to it
    #>
    param(
        # URI of Slack Hook
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Uri,
        # Message To Send
        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $Message
    )
    
    $payload = @{
        "text" = $Message
    }

    Invoke-RestMethod -Method Post -Uri $Uri  -Body (ConvertTo-Json -InputObject $payload -Compress) -UseBasicParsing | Out-Null
}

$uri = Get-AutomationVariable -Name 'SlackWebHookUri'
$deletedObjectContainer = (get-addomain).DeletedObjectsContainer

$searchstring = "$($request.Message)"
$searchstring = $searchstring.Trim()

$userList = Get-ADObject -SearchBase $deletedObjectContainer -IncludeDeletedObjects -filter "sAMAccountName -like '*$searchstring*'" -Properties userPrincipalName, sAMAccountName |
Select-Object userPrincipalName, sAMAccountName


$foundDeletedUsers = New-Object -TypeName System.Collections.Generic.List[pscustomobject]
$foundDeletedUsers.Add("Found the following deleted samAccountNames:")

Foreach ($user in $userList) {
    $foundDeletedUsers.add("`n$($user.sAMAccountName)")
}

New-MDSlackMessage -uri $uri -Message $foundDeletedUsers