Configuration PoshbotConfig {
        param(
        [string[]]$ComputerName = "localhost",
        [string[]]$FolderName
    )
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'RegionSettings'
    Import-Dscresource -ModuleName 'PackageManagement'

    Node $ComputerName {

        $directoryList = 'Poshbot', 'Poshbot\plugins', 'Poshbot\logs'   
        WindowsFeature SMB1 {
            Ensure = 'Absent'
            Name = 'FS-SMB1'
        }

        PackageManagement PoshbotModule {
            Ensure = 'Present'
            Name = 'Poshbot'
        }
        foreach ($dir in $directoryList) {
            File $dir{ 
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = "C:\$dir"
            }
        }
           


        UKRegion UK {

        }

    }
}