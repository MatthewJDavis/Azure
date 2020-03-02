param(
  [Parameter(Mandatory = $true)]
  [String]
  $ContainerUri
)

Write-Output $ContainerUri

$result = Invoke-WebRequest -UseBasicParsing -Uri $ContainerUri

Write-Output $result

if ($result.Content.Contains('Thank you for using nginx.')) {
  Write-Output 'Success, the website has the correct wording'
  Return 0
} else {
  Write-Output 'Failure, the wording on the website is wrong'
  Return 1
}

