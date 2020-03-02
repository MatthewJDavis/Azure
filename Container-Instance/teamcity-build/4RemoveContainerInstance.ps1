param(
  [Parameter(Mandatory = $true)]
  [String]
  $ResourceGroup,
  [Parameter(Mandatory = $true)]
  [String]
  $ContainerGroupName
)

Remove-AzureRmContainerGroup -ResourceGroupName $ResourceGroup -Name $ContainerGroupName