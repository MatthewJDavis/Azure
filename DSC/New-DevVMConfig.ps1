Configuration DevVM {
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName xStorage
    Import-DscResource -ModuleName xTimeZone
    Import-DscResource -ModuleName xSQLServer
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName SystemLocaleDsc

    Node 'localhost'
    {
        WindowsFeature InstallWebServer
        {
          Name = 'Web-Server'
          Ensure = 'Present'
        }
        WindowsFeature InstallIISConsole 
        {
            Name = 'Web-Mgmt-Console'
            Ensure = 'Present'
        }
        WindowsFeature InstallDotNet45
        {
            Name = 'Web-Asp-Net45'
            Ensure = 'Present'
        }        
        xWaitForDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec = 60
            RetryCount = 60
        }
        xDisk FVolume
        {
            DiskNumber = 2
            DriveLetter = 'F'
            FSLabel = 'SQL'
        }        
        File SQLDataDir
        {
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = 'F:\SQLServer\DATA'
        }
        File SQLLogDir
        {
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = 'F:\SQLServer\LOG'
        }
        File SQLBackupDir
        {
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = 'F:\SQLServer\BACKUP'
        }
        Registry SetSQLDefaultDataDir 
        {
            Ensure = 'Present'
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer"
            ValueName = "DefaultData"
            ValueData = "F:\SQLServer\DATA"
            ValueType = "String" 
        }
        Registry SetSQLDefaultLogDir 
        {
            Ensure = 'Present'
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer"
            ValueName = "DefaultLog"
            ValueData = "F:\SQLServer\LOG"
            ValueType = "String" 
        }
        Registry SetSQLDefaultBackupDir 
        {
            Ensure = 'Present'
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer"
            ValueName = "BackupDirectory"
            ValueData = "F:\SQLServer\BACKUP"
            ValueType = "String" 
        }
        xTimeZone GMT
        {
            TimeZone         = 'GMT Standard Time'
            IsSingleInstance = 'Yes'
        }
        SystemLocale SystemLocaleExample
        {
            SystemLocale     = 'en-GB'
            IsSingleInstance = 'Yes'
        }       
    }
}
