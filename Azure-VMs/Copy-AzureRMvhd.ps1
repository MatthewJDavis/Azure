# VHD blob to copy #
$blobName = "md-ubuntu-1.vhd" 

# Source Storage Account Information #
$sourceStorageAccountName = "testresourcegroup5498"
$sourceKey = ""
$sourceContext = New-AzureStorageContext –StorageAccountName $sourceStorageAccountName -StorageAccountKey $sourceKey  
$sourceContainer = "vhds"

# Destination Storage Account Information #
$destinationStorageAccountName = "testresourcegroup1466"
$destinationKey = ""
$destinationContext = New-AzureStorageContext –StorageAccountName $destinationStorageAccountName -StorageAccountKey $destinationKey  

# Create the destination container #
$destinationContainerName = "vhds"
New-AzureStorageContainer -Name $destinationContainerName -Context $destinationContext 

# Copy the blob # 
$blobCopy = Start-AzureStorageBlobCopy -DestContainer $destinationContainerName `
                        -DestContext $destinationContext `
                        -SrcBlob $blobName `
                        -Context $sourceContext `
                        -SrcContainer $sourceContainer

while(($blobCopy | Get-AzureStorageBlobCopyState).Status -eq "Pending")
{
    Start-Sleep -s 30
    $blobCopy | Get-AzureStorageBlobCopyState
}
