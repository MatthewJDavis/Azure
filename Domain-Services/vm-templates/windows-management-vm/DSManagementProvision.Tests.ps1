Describe  'AzureVM' {

        BeforeAll {
            #Add-AzureRmAccount
            $rgName = 'domain-services-rg'
            $vmName = 'ds-manag-vm'
            $location = 'northeurope'
            $rg = Get-AzureRmResourceGroup -Name $rgName
            $vm = Get-AzureRmVM -ResourceGroupName $rg.ResourceGroupName -Name $vmName
        }

        Context AzureVM {
            It "The VM should be in $rgName" {
                $vm.ResourceGroupName | Should Be $rgName
            }
            It "The VM should be located in $location" {
                $vm.location | Should Be $location
            }
        }
}
