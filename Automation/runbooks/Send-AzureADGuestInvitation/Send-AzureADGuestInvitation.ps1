<#
.SYNOPSIS
Invite guest users Azure Active Directory for Azure AD application.
.DESCRIPTION
Users to be provided in CSV file with the headings 'firstname,surname,email'.
Users will be be checked to see if they have been invited to Azure AD as a guest user previously. If there is already an invite, then no action will be take, if a user doesn't exist in the Azure AD, then an invite will be sent.
.NOTES
https://docs.microsoft.com/en-us/azure/active-directory/b2b/b2b-quickstart-invite-powershell
#>

$userList = Import-Csv -Path ./guests.csv

$demoGroupId = ''
$date = Get-Date -Format yyyy-mm-dd

function New-UserInvite {
    $invite = New-AzureADMSInvitation -InvitedUserDisplayName $displayName -InvitedUserEmailAddress $user.email -SendInvitationMessage $true -InviteRedirectUrl $url
    Add-AzureADGroupMember -ObjectId $demoGroupID -RefObjectId $invite.InvitedUser.Id
    Write-Output "$($invite.InvitedUserEmailAddress) invited on $date. Added to demo AAD group."
}

foreach ($user in $userList) {
    $displayName = "$($user.firstname) $($user.surname)"
    $url = 'https://myapps.microsoft.com/?tenantid='
    $ExistingUserList = Get-AzureADUser -SearchString $displayName | Where-Object -FilterScript { $_.UserType -eq 'guest' }

    if ($ExistingUserList.Count -gt 0) {
        # User has potentially been invited before, need to check
        foreach ($existingUser in $ExistingUserList) {
            if ($existingUser.mail -eq $user.email) {
                Write-Output "User with email address already has been invited: $($user.email)"
            }
            else {
                New-UserInvite
            }
        }
    }
    else {
        New-UserInvite
    }
}