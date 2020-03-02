$rgName = 'domain-services-rg'
$location = 'Northeurope'
$vnetName = 'northeurope-vnet'
$addressPrefix = '10.1.0.0/16'
$subName1 = 'gateway-sub'
$subAddress1 = '10.1.0.0/28' 
$subName2 = 'frontend-sub'
$subAddress2 = '10.1.1.0/24' 
$subName3 = 'backend-sub'
$subAddress3 = '10.1.2.0/24' 

# create resource group
New-AzureRmResourceGroup -Name $rgName -Location $location -Tag @{"Name" = "domain-services"}

#create three subnets
$Subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name $subName1 -AddressPrefix $subAddress1  
$Subnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name $subName2 -AddressPrefix $subAddress2 
$Subnet3 = New-AzureRmVirtualNetworkSubnetConfig -Name $subName3 -AddressPrefix $subAddress3


$params = @{
    "ResourceGroupName" = $rgName;
    "Name" = $vnetName;
    "Location" = $location;
    "AddressPrefix" = $addressPrefix;
    "Subnet" = $Subnet1, $Subnet2, $Subnet3
}

New-AzureRmVirtualNetwork @params

