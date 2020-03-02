function Get-MDSSLCertificateExpiry {
    <#
    .SYNOPSIS
        Get the expiry date of an SSL certificate from a website.
    .DESCRIPTION
        Connects to a give uri and returns the expiry date and uri of the website
    .EXAMPLE
    Get-MDSSLCertificateExpiry -Uri 'https://matthewdavis111.com'
    ExpiryDate          Uri
    ----------          ---
    16/10/2019 19:59:59 https://matthewdavis111.com
    Returns the expiry date of the ssl certificate from https://matthewdavis111.com
    .NOTES
        Not working on PowerShell core, ServicePoint.Certificate is empty
    #>
    #Requires -Version 5.1
    [CmdletBinding()]
    param (
        # Specifies the Uniform Resource Identifier (URI) of the Internet resource to which the web request is sent. Enter a URI. https:// is required
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Uri
    )
    
    begin {
    }
    
    process {
        try {
            $request = [System.Net.HttpWebRequest]::Create($uri)
            $request.GetResponse().Dispose()
            $cert = $request.ServicePoint.Certificate

            $properties = @{
                ExpiryDate = $cert.GetExpirationDateString()
                Uri        = $Uri
            }
            $Output = New-Object -TypeName pscustomobject -Property $properties
            $Output
            
        } catch {
            Write-Error  $_.Exception.Message
        }
    }
    
    end {
    }
}

# Slack helper function
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

    Invoke-RestMethod -Method Post -Uri $SlackHook  -Body (ConvertTo-Json -InputObject $payload -Compress) -UseBasicParsing | Out-Null
}

$UriList = 'web.example.com', 'test.example.com'
$Date = Get-Date
$SlackHook = Get-AutomationVariable -Name 'SlackWebHookUri'
$UriList | foreach-Object {
    $WebRequest = Get-MDSSLCertificateExpiry -Uri $_

    $ExpiryDate = [datetime]::Parse($WebRequest.ExpiryDate)

    # Alert if there is less than 14, 7 or 3 days remaining.

    if ($ExpiryDate.AddDays(-14) -lt $Date) {
        $Message =  "Cert Expiring in the next 14 days`n$_ Expires: $($ExpiryDate.ToString('yyyy-MM-dd'))"
    }  
    if ($ExpiryDate.AddDays(-7) -lt $Date) {
        $Message =  "Cert Expiring in the next 7 days`n$_ Expires: $($ExpiryDate.ToString('yyyy-MM-dd'))"
    }  
    if ($ExpiryDate.AddDays(-3) -lt $Date) {
        $Message =  "Cert Expiring in the next 3 days`n$_ Expires: $($ExpiryDate.ToString('yyyy-MM-dd'))"
    }  
    New-MDSlackMessage -Uri $SlackHook -Message $Message
    Write-Output $Message 
    # Clear message varibale value  
    $Message = $Null
}
