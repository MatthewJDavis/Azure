param(
  [Parameter(Mandatory = $true)]
  [String]
  $ContextName
)

Disconnect-AzureRmAccount -ContextName $ContextName