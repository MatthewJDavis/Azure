Configuration DSManagSrvConfig {
        param(
        [string[]]$ComputerName = "localhost"
    )
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node $ComputerName {
        WindowsFeature SMB1 {
            Ensure = 'Absent'
            Name = 'FS-SMB1'
        }
        WindowsFeature AD-Tools {
            Ensure = 'present'
            Name = 'RSAT-AD-Tools' 
        }
        WindowsFeature AD-PowerShell {
            Ensure = 'present'
            Name = 'RSAT-AD-PowerShell' 
        }
        WindowsFeature DNS-Tools {
            Ensure = 'present'
            Name = 'RSAT-DNS-Server' 
        }
        WindowsFeature Group-Policy-Management {
            Ensure = 'present'
            Name = 'GPMC'
        }
    }
}

DSManagSrvConfig