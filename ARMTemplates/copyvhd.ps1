$blobName = "InfaBaseVM01-os-2015-11-16.vhd" 

# Source Storage Account Information #
$sourceStorageAccountName = "portalvhdsvh52szjygn3kh"
$sourceKey = "xmUIp129XMo+XI44Fg0otkxRQaGWgqzDyUe2BTzl5w6LemFHi8cnhRv1o+dKmDwt63VbCLFUW5i4b7ZVJgwqSQ=="
$sourceContext = New-AzureStorageContext –StorageAccountName $sourceStorageAccountName -StorageAccountKey $sourceKey  
$sourceContainer = "vhdscopy"

# Destination Storage Account Information #
$destinationStorageAccountName = "ispstorenp"
$destinationKey = "F69NSSLFYJyEX3JRCeGkZ1Pq5pc2w3Ms3nRji3g2HwISMu0BukGzTfHawywhm1ZPxCC919s8/m6+J6puNRXhug=="
$destinationContext = New-AzureStorageContext –StorageAccountName $destinationStorageAccountName -StorageAccountKey $destinationKey  

# Create the destination container #
#$destinationContainerName = "copiedvhds"
#New-AzureStorageContainer -Name $destinationContainerName -Context $destinationContext 

# Copy the blob # 
$blobCopy = Start-AzureStorageBlobCopy -DestContainer $destinationContainerName `
                        -DestContext $destinationContext `
                        -SrcBlob $blobName `
                        -Context $sourceContext `
                        -SrcContainer $sourceContainer