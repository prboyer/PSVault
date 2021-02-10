# Quick script to remove user device affinity associations from SCCM CM.
# Written by Paul B. 10-28-2019
#####################################################
$adminAccount = "primo\paul"
$userAccount = "primo\pboyer2"

# Declare array for user primay keys
$userIDs = @();

# Query SCCM CM for primary key (ID) for my admin user account
$userIDs += (Get-CMUser -Name $adminAccount | select ResourceID).ResourceID

# Query SCCM CM for primary key for my non-admin account
$userIDs += (Get-CMUser -Name $userAccount | select ResourceID).ResourceID

# Declare array of device primary keys
$deviceIDs = @();

# Add device primary keys to array
$deviceIDs += (Get-CMDevice -Name "irp-pc366" | select ResourceID).ResourceID
$deviceIDs += (Get-CMDevice -Name "irp-pc367" | select ResourceID).ResourceID

# Remove my account from the primary user association
foreach($device in $deviceIDs){
    foreach ($user in $userIDs){
        Remove-CMUserAffinityFromDevice -DeviceId $device -UserId $user -Force
    }
}