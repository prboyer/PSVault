function Convert-SubnetMaskCIDR{
    <#
    .SYNOPSIS
    Converts a subnet mask to a CIDR notation

    .DESCRIPTION
    Converts a subnet mask to a CIDR notation by first converting the subnet mask to a binary string. Then it summaries the binary string and converts the summaries to a CIDR notation.
    
    .PARAMETER SubnetMask
    The subnet mask to convert.
    
    .EXAMPLE
    C:\PS>Convert-SubnetMaskCIDR 255.255.255.0

    Converts 255.255.255.0 to CIDR notation (/24)
    
    .NOTES
        Author: Paul Boyer
        Date: 07-07-2021

        https://docs.netgate.com/pfsense/en/latest/network/cidr.html
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $SubnetMask
    )

    <# Convert the subnet mask in dotted-decimal format to binary #>
        # First, break the subnet mask into octets. Then convert each octet to binary.
        [Object]$SubnetMaskBinary = $SubnetMask -split "\." | ForEach-Object {
            [System.Convert]::ToString($_,2).PadLeft(8,"0")
        }

        # Then, combine each octet in binary into a single 32-bit number.
        $SubnetMarkBinary = $($SubnetMaskBinary -join " ").Replace(" ","")
        [Int]$CIDRMask = ($SubnetMaskBinary.ToCharArray() | Where-Object {$_ -eq "1"} | Measure-Object).Count

        return $CIDRMask
}