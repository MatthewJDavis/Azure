# config settings - get DNS Server addresses from the portal under the AAD Domain Services blade
$vnetName = 'northeurope-vnet'
$vnetRg = 'domain-services-rg'
$dnsServer1 = '10.0.0.4'
$dnsServer2 = '10.0.0.5'

$vnet = get-azurermvirtualnetwork -Name $vnetName -ResourceGroupName $vnetRg

# Add the DNS Server values to the VNET var
$vnet.DhcpOptions.DnsServers = $dnsServer1
$vnet.DhcpOptions.DnsServers += $dnsServer2

# set the DNS servers for the vnet
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet