Configuration BasicServerConfig {
        param(
        [string[]]$ComputerName = "localhost"
    )
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName xStorage

    Node $ComputerName {
        WindowsFeature SMB1 {
            Ensure = 'Absent'
            Name = 'FS-SMB1'
        }
        File Temp{ 
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = 'C:\Temp'
        }
    }
}
