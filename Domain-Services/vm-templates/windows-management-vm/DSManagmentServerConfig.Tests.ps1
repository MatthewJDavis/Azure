Describe 'Management VM Config' {
    
  Context 'Management Tools' {
      It 'Should have the Remote Server Admin Tools AD feature installed' {
        (Get-WindowsFeature -Name RSAT-AD-Tools).installed | Should Be $true
      }
      It 'Should have the Remote Server Admin Tools AD PowerShell feature installed' {
         (Get-WindowsFeature -Name RSAT-AD-PowerShell).installed | Should Be $true
      }
      It 'Should have the Remote Server Admin Tools DNS feature installed' {
        (Get-WindowsFeature -Name RSAT-DNS-Server).installed | Should Be $true
      }
      It ('Should have Group Policy Management insatlled') {
        (Get-WindowsFeature -Name GPMC).installed | Should Be $true
      }
    }
  Context 'Security' {
    It 'Should not have SMB 1 installed' {
      (Get-WindowsFeature -Name FS-SMB1).installed | Should Be $false
    }
  }
}
