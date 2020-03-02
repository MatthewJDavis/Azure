param(
  [Parameter(Mandatory = $true)]
  [String]
  $ApplicationId,
  [Parameter(Mandatory = $true)]
  [String]
  $TenantId,
  [Parameter(Mandatory = $true)]
  [String]
  $Thumbprint,
  [Parameter(Mandatory = $true)]
  [String]
  $ContextName
  
)

$authParams = @{
  'ServicePrincipal'      = $true;
  'CertificateThumbprint' = $Thumbprint;
  'ApplicationId'         = $ApplicationId;
  'Tenant'                = $TenantId;
  'ContextName'           = $ContextName
}

Connect-AzureRmAccount @authParams