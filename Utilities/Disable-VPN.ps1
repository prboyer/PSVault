function Disable-VPN {
    <#
    .SYNOPSIS
    Disables a VPN connection given the appropriate environmental criteria is met.    
    
    .DESCRIPTION
    Checks if the PC is connected to Ethernet, and if the IP address is on the right LAN. If both conditions are met, the VPN is disabled (optionally Wi-Fi turned off too).

    .PARAMETER WiFi
    Switch to disable Wi-Fi.
    
    .EXAMPLE
    PS C:\> Disable-VPN

    Disables the VPN connection.
    
    .EXAMPLE

    PS C:\> Disable-VPN -WiFi

    Disables the VPN connection and turns off Wi-Fi.

    .NOTES
        Author: Paul Boyer
        Date: 07-07-2021
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [Switch]
        $WiFi
    )
    
    <# Import Modules #>
        #Requires -Version 5.1
        #Requires -Module Subnet

        Import-Module Subnet

    <# Variables #>
        # Name of the VPN service
        [String]$VPNService = "PanGPS"

    <# If connected to ethernet, and assigned an appropriate IP address, disable the VPN #>
        # Object that represents the local ethernet adapter
        [Object]$Ethernet = Get-NetAdapter -Name "Ethernet"
        
        # Check if the ethernet adapter is connected
        if ($Ethernet.Status -eq "Up") {
            # If WiFi parameter is specified, then disable the WiFi interface
            if($WiFi){
                # if connected to ethernet, then disable Wi-Fi
                Disable-NetAdapter -Name "Wi-Fi" -Confirm:$false
            }
              
            # Create a local subnet object to store all possible host IP addresses given current ethernet connection configuration
            [Object]$LocalSubnet = Get-Subnet -IP $(Get-NetIPAddress -InterfaceIndex $Ethernet.ifIndex -AddressFamily IPv4).IPAddress -MaskBits $(Get-NetIPAddress -InterfaceIndex $Ethernet.ifIndex -AddressFamily IPv4).PrefixLength
            
            # If the current ethernet adapter IP address is in the local subnet, then disable the VPN
            if($(Get-NetIPAddress -InterfaceIndex $Ethernet.ifIndex -AddressFamily IPv4).IPAddress -in @($LocalSubnet.HostAddresses)){
                Get-Service -Name $VPNService | Stop-Service
            }
        }else{
            # Re-enable the Wi-Fi adapter
            Enable-NetAdapter -Name "Wi-Fi"

            # Re-enable the VPN
            Get-Service -Name $VPNService | Start-Service
        }
}