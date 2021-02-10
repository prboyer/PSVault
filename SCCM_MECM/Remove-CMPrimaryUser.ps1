function Remove-CMPrimaryUser {
    <#
    .SYNOPSIS
    A script to remove user device affinity associations from devices in SCCM for a given user
    
    .DESCRIPTION
    The script will remove a given user's device affinity associations from SCCM from all machines, or if a parameter is passed
    the device affinity will be removed for a user on specific machines. 
    
    .PARAMETER Users
    A String array of usernames. These can be either fully-qualified usernames (Contoso\BillG) or just sAM Account Names (Bill G). Multiple usernames can be passed 
    
    .PARAMETER Computers
    A String array of computer names. These need not be fully-qualified. The parameter can accept multiple computer names. 
    
    .PARAMETER Domain
    The NetBIOS name of the domain. The script will implicitly grab the NetBIOS name from the current domain unless another is passed at runtime.
    
    .EXAMPLE
    Remove-CMPrimaryUser -Username "Contoso\BillG","Contoso\SteveB"

    .EXAMPLE
    Remove-CMPrimaryUser -Username "BillG" -Computers "server01" -Domain "Fabrikam"
    
    .NOTES
    Paul B. 10-28-2019
    #>
    param (
        [Parameter (Mandatory=$True)]
        [String[]]
        $Users,
        [Parameter()]
        [String[]]
        $Computers,
        [Parameter()]
        [String]
        $Domain
    )

    # Try to get domain prefix implicitly if not passed
    [String]$domainPrefix;

    if($Domain -eq ""){
        Import-Module ActiveDirectory
        $domainPrefix = $(Get-ADDomain).NetBIOSName 
    }else{
        $domainPrefix = $Domain
    }

    # Declare array for user primary keys
    $userIDs = @();

    # Declare array of device primary keys
    $deviceIDs = @();

    # Query SCCM CM for primary key (ID) for user account
    $Users | %{
        if(-not ($_ -ilike "$domainPrefix\*")){
            $userIDs += (Get-CMUser -Name "$domainPrefix\$_" | Select-Object ResourceID).ResourceID
        }else{
            $userIDs += (Get-CMUser -Name $_ | Select-Object ResourceID).ResourceID
        }
    }

    if(($Computers -ne "") -and ($Computers -ne $null)){
        # Add device primary keys to array
        $Computers | %{
            $deviceIDs += (Get-CMDevice -Name $_ | Select-Object ResourceID).ResourceID 
        }
    }else{
        # Get the resource ID of all computers in SCCM if computers are not specified. 
        $deviceIDs = (Get-CMDevice -Fast | Select-Object ResourceID)
    }

    # Remove my account from the primary user association
    foreach($device in $deviceIDs){
        foreach ($user in $userIDs){
           Remove-CMUserAffinityFromDevice -DeviceId $device -UserId $user -Force
        }
    }
}