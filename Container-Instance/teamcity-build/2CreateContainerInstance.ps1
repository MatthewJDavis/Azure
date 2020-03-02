param(
  [Parameter(Mandatory = $true)]
  [String]
  $ResourceGroup
)

$prefix = -join ((97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})
$date = Get-Date -Format yyyyMMddHHMMss
$ContainerGroupName = "tc-testing-containers-$date"
$DnsName = "$prefix-$date"
$OsType = 'Linux'
$Port = '80'
$ContainerImage = 'nginx'


$containerGroupParams = @{
  'ResourceGroupName' = $ResourceGroup;
  'Name'              = $ContainerGroupName;
  'Image'             = $ContainerImage;
  'DnsNameLabel'      = $DnsName;
  'OsType'            = $OsType;
  'Port'              = $Port
}

$containerGroup = New-AzureRmContainerGroup @containerGroupParams

# Wait for the container to start running before testing the connection
while ((Get-AzureRmContainerGroup -ResourceGroupName $ResourceGroup -Name $ContainerGroupName).State -ne 'running') {
  Write-Output "Container state is: $((Get-AzureRmContainerGroup -ResourceGroupName $ResourceGroup -Name $ContainerGroupName).State)"
  Start-Sleep -Seconds 5
}

Write-Output "Container is: $((Get-AzureRmContainerGroup -ResourceGroupName $ResourceGroup -Name $ContainerGroupName).State)"

# Test that the after the container is running, wait until we can get a TCP connection on the container
while ((Test-NetConnection -ComputerName $containerGroup.Fqdn -Port $Port).TcpTestSucceeded -ne 'True') {
  Write-Output 'Waiting for Nginx'
  Start-Sleep -Seconds 5
}

# Update the TeamCity build parameters for use in later build steps
"##teamcity[setParameter name='containerGroupName' value='$ContainerGroupName']"
"##teamcity[setParameter name='containerUrl' value='$($containerGroup.Fqdn)']"

