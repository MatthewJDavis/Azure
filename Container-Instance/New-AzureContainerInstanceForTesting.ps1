# Create Azure Container instance, test against it and remove it.
# https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quickstart-powershell


#vars
# Create the random string of 5 letters for the dns name of the container
# 97 to 122 is the ASCII for lowercase letters
$prefix = -join ((97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})

$date = Get-Date -Format yyyyMMddHHMMss

$ResourceGroup = 'tc-containers'
$ContainerGroupName = "tc-testing-containers-$date"
$DnsName = "$prefix-$date"
$OsType = 'Linux'
$Port = '80'
$ContainerImage = 'nginx'

# Authenticate

#create
$containerGroup =  New-AzureRmContainerGroup -ResourceGroupName $ResourceGroup -Name $ContainerGroupName -Image $ContainerImage -DnsNameLabel $DnsName -OsType $OsType -Port $Port

# Wait for container group to become available
$i = 0
while ((Get-AzureRmContainerGroup -ResourceGroupName $ResourceGroup -Name $ContainerGroupName).State -ne 'running') {
  Write-Output (Get-AzureRmContainerGroup -ResourceGroupName $ResourceGroup -Name $ContainerGroupName).State
  Start-Sleep -Seconds 5
  $i ++
  if ($i -eq 5){
    Write-Output 'Something went wrong creating the container group, check Azure for further info'
    throw
  }
}

Write-Output (Get-AzureRmContainerGroup -ResourceGroupName $ResourceGroup -Name $ContainerGroupName).State

# test

while ((Invoke-WebRequest -UseBasicParsing -Uri $containerGroup.Fqdn).StatusCode -ne 200)) {
  Start-Sleep -Seconds 5
}

$result = Invoke-WebRequest -UseBasicParsing -Uri $containerGroup.Fqdn

if ($result.StatusCode -eq 200) {
  Write-Output 'Success'
} else {
  Write-Output 'Failure'
}

# destroy
Remove-AzureRmContainerGroup -ResourceGroupName $ResourceGroup -Name $ContainerGroupName 
