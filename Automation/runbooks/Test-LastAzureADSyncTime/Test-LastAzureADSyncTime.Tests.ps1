$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'


# Create empty functions for cmdlets not on system to be mocked later
  function Get-AutomationPSCredential {}
  function Connect-MsolService {}
  function Get-MsolCompanyInformation {}
Describe "Test-LastAzureADSyncTime" {
    function Get-AutomationPSCredential {}
    Mock Import-Module { }
    Mock Connect-MsolService -MockWith { }
    Mock Get-AutomationPSCredential -MockWith {  }

    Mock Get-MsolCompanyInformation -MockWith {
        [PSCustomObject]@{ 
            LastDirSyncTime = (Get-Date).AddHours(-10) 
        }
    }
    $r = . "$here\$sut"
    It "Sync ran 3 hours ago. Returns a message containing Azure" {
        $r | Should -BeLike "Azure*"
    }

    Mock Get-MsolCompanyInformation -MockWith {
        [PSCustomObject]@{ 
            LastDirSyncTime = (Get-Date).AddHours(-10) }
    }
    $r = . "$here\$sut"

    It "Sync ran 10 hours ago. Returns a message containing Azure" {
        $r | Should -BeLike "Azure*"
    }
    Mock Get-MsolCompanyInformation -MockWith {
        [PSCustomObject]@{ 
            LastDirSyncTime = (Get-Date).AddHours(-1) 
        }
    }

    $r = . "$here\$sut"
    It "Sync ran one hour ago so no output" {
        $r | Should -Be $null
    }
    Mock Get-MsolCompanyInformation -MockWith {
        [PSCustomObject]@{ 
            LastDirSyncTime = (Get-Date).AddMinutes(-30) 
        }
    }
    $r = . "$here\$sut"
    It "Sync ran 30 minutes ago so no output" {
        $r | Should -Be $null
    }
}

