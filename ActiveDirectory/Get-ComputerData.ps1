function Get-ComputerData{
    <#
    .SYNOPSIS
    Cmdlet to quickly return information about a AD-joined computer
    
    .DESCRIPTION
    Script returns:
    - Operating System
    - Operating System Version
    - Hardware Vendor
    - Hardware Model
    - Serial Number
    - Last logged on user
    - Last logon date & time
    
    This is returned to standard out. Optionally, the information can be exported to a CSV by supplying a value to -Path.
    .PARAMETER ComputerName
    Required. The name of the computer for which the script should query for information. The script does a wildcard lookup so partial names for the parameter are acceptable. 
    
    .PARAMETER Path
    Path to save an output file. The script will automatically supply a file name with a *.CSV extension. Includes datestamp in file name.
    
    .EXAMPLE
    Get-ComputerData -ComputerName Computer001

    .EXAMPLE
    Get-ComputerDate -ComputerName Computer001 -Path C:\Temp

    .EXAMPLE
    Get-ComputerData -ComputerName Comp
    
    .NOTES
    This script pulls custom attributes from AD DS. The Model, Hardware Vendor, Last Logged On User, and Last Logged On User Date & Time are custom attributes from the AD DS environment the script was composed in.
    YMMV when using this script in other environments without these fields.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateLength(1,100)]
        [String]
        $ComputerName,
        [Parameter]
        [String]
        $Path
    )

    [string]$COMPUTER = "*"+$ComputerName+"*";

    # Gather information from ActiveDirectory based on the supplied computer name
    $output = Get-ADComputer -Filter 'Name -like $COMPUTER' -Properties sSCCHardwareModel, sSCCHardwareVendor, serialNumber, sSCCLastLoggedOnUser, sSCCLastLoggedOnUserDate, operatingSystem, operatingSystemVersion |
        Select-Object Name, operatingSystemVersion, sSCCHardwareVendor, sSCCHardwareModel, serialnumber, sSCCLastLoggedOnUser, sSCCLastLoggedOnUserDate | Sort-Object -Property Name 
        
    $output | Format-Table

    # Output results to a file if the -Path parameter is supplied
    if($Path -ne $null){
        Export-Csv -NoTypeInformation -InputObject $output -Path "$Path\Get-ComputerData_$(Get-Date -Format s).csv" -Force
    }
}