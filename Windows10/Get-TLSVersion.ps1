function Get-TLSVersion {
    <#
    .SYNOPSIS
    Short script that returns the current TLS version settings

    .DESCRIPTION
    Script uses .NET methods to get the current TLS version settings. Then prints out results to console. Also returns current setting as a string.

    .EXAMPLE
    Get-TLSVersion

    .OUTPUTS
    String with current system setting for connection security.

    .LINK
    https://www.eshlomo.us/check-and-update-powershell-tls-version/

    .NOTES
        Author: Paul Boyer
        Date: 4-14-21
    #>

    $output = [enum]::GetNames([Net.SecurityProtocolType]) | Select-Object @{name='Name'; expression={$_}} , @{name='CurrentSetting'; expression={if($_ -eq [Net.ServicePointManager]::SecurityProtocol){" < "}}}

    Write-Information $($output | Out-String) -InformationAction Continue

    return [Net.ServicePointManager]::SecurityProtocol.ToString()
}