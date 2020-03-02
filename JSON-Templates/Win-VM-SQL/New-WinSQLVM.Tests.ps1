Describe 'New-WinSQLVM' {
    $jsonPath = 'C:\git\Azure\JSON-Templates\Win-VM-SQL\ConfigurationItems.json' 
    
    $expectedValues = (get-content -Path $jsonPath -Raw | ConvertFrom-Json).ConfigurationItems

    
    function Get-ExpectedValue {
        param(
            [string]$Path
        )

        $split = $Path -split '\\'
        if ($split.Count -eq 2) {
            ($expectedValues | where {$_.PSObject.Properties.Name -eq $split[0]}).($split[0]).($split[1]) -join ''
        } else {
            ($expectedValues.($split[0]) | where {$_.PSObject.Properties.Name -eq $split[1]}).($split[1]).($split[2]) -join ''
        }
    }

    BeforeAll {
        #Add-AzureRmAccount
        $rg = Get-ExpectedValue 'VirtualMachine\ResourceGroupName'
        $vmName = Get-ExpectedValue 'VirtualMachine\Name'
        $vm = Get-AzureRmVM -ResourceGroupName $rg -Name $vmName
        $homeIP = Invoke-RestMethod -Uri  'https://api.ipify.org?format=json'
        $nsgName = Get-ExpectedValue 'NetworkSecurityGroup\Name' 
        $nsgRg = Get-ExpectedValue 'NetworkSecurityGroup\ResourceGroupName'
        $nsg = Get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $nsgRg 
    }
    
    Context 'Azure VM resouce'{
        It 'The vm should be in the resource group matt-dev-vm-rg' {
        $vm.ResourceGroupName | should be (Get-ExpectedValue -Path 'VirtualMachine\ResourceGroupName')
        }

        It 'The vm resource should be called matt-dev-1' {
        $vm.Name | should be (Get-ExpectedValue -Path 'VirtualMachine\Name')
        }

        It 'The vm should be located in the uksouth region' {
        $vm.Location | should be (Get-ExpectedValue -Path 'VirtualMachine\Location')
        }
    }
    Context 'Network Security Group'{
        It 'The Network Security Group should be called matt-dev-1-nsg' {
        $nsg.Name | should be (Get-ExpectedValue -Path 'NetworkSecurityGroup\Name')
        }
            
        It 'The Network security group should be in the resource group matt-dev-vm-rg' {
        $nsg.ResourceGroupName | should be (Get-ExpectedValue -Path 'NetworkSecurityGroup\ResourceGroupName')
        }
    }

    
    Context 'Network Security Group Config' {
        It 'The network security group config should allow the rdp from the local ip address' {
        (Get-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg).SourceAddressPrefix | should be $ip.ip  
        }
    }
}