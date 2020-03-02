# Set up vnet perring between the classic and ARM vnet
$resourceGroupName = 'domain-services-rg'
$classicVnetName = 'domain-services-vnet'
# Enter the name of the AzureRM subscription the VNETs are deployed in. Run (Get-AzureRmSubscription).SubscriptionName after authenticating to AzureRM
$subScriptionName = ''

# save current vnet in var
$vnet = Get-AzureRmVirtualNetwork -Name northeurope-vnet -ResourceGroupName domain-services-rg

# create the id for the classic vnet - we need the subscription id, resource group name and classic vnet to form the id
$subscriptionId = (Get-AzureRmSubscription -SubscriptionName $subScriptionName).SubscriptionId
$id = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.ClassicNetwork/virtualNetworks/$classicVnetName"

Add-AzureRmVirtualNetworkPeering -Name domain-service-peering -VirtualNetwork $vnet -RemoteVirtualNetworkId $id



