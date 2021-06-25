function Set-TLSVersion {
    <#
    .SYNOPSIS
    Short script to set the Security Protocol

    .DESCRIPTION
    Using the .NET methods, the script sets the Security Protocol to the value passed by -Version parameter

    .PARAMETER Version
    String for the Security Protocol that should be set

    .PARAMETER Registry
    Parameter description

    .EXAMPLE
    Set-TLSVersion -Version Tls12

    .LINK
    https://www.eshlomo.us/check-and-update-powershell-tls-version/

    .NOTES
        Author: Paul Boyer
        Date: 4-14-21
    #>
    param (
        [Parameter(Mandatory=$True)]
        [ValidateSet("Ssl3","Tls","Tls11","Tls12","Tls13")]
        [String]
        $Version,
        [Parameter()]
        [switch]
        $Registry
    )
    #Requires -Version 5.1

    # Make the change in the registry so that the Security Protocol will be updated across sessions on the system
    if ($Registry) {
        Write-Error -ErrorAction Continue -Exception ([System.Management.Automation.PSNotImplementedException]::new("-Registry parameter not implemented"))
    }

    Write-Information $("Setting Security Protocol to {0}" -f $Version)

    # Set the Security Protocol to the version specified in the -Version parameter.
    [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::$Version

    # Return the result of setting the Security Protocol as a string on standard out
    return [String]$("The Security Protocol has been set to {0}" -f [Net.ServicePointManager]::SecurityProtocol.ToString() )
}