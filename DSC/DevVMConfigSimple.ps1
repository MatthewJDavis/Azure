Configuration DevVM {
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    
    Node "DevVMNode"
    {
        WindowsFeature InstallWebServer
        {
          Name = "Web-Server"
          Ensure = "Present"
        }
        WindowsFeature InstallIISConsole {
 
            Name = 'Web-Mgmt-Console'
            Ensure = 'Present'
        }
        WindowsFeature InstallDotNet45
        {
            Name = "Web-Asp-Net45"
            Ensure = "Present"
        }       
        
    }
}