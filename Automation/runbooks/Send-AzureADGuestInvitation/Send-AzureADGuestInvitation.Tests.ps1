$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

# Create empty functions for cmdlets not on system to be mocked later
  function New-AzureADMSInvitation {}
  function Add-AzureADGroupMember {}
  function Get-AzureADUser {}


  