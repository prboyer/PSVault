function Set-SystemInformation {
    <#
    .SYNOPSIS
    Script to update the manufacturer information from the System Control Panel page
    
    .DESCRIPTION
    The OEM (Original Equipment Manufacturer) support information in Windows includes the logo, manufacturer, model, support hours, support phone, and support URL for your PC
    
    .PARAMETER LogoFile
    String filepath to *.bmp logo file
    
    .PARAMETER Manufacturer
    String name of the manufacturer to override the value from WMI     

    .PARAMETER Model
    String name of the model to override the value from WMI     
    
    .PARAMETER SupportHours
    String indicating the help desk's support hours

    .PARAMETER SupportPhone
    String indicating the help desk's phone number
    
    .PARAMETER SupportURL
    String indicating the help desk's website or web portal
    
    .EXAMPLE
    Set-SystemInformation -LogoFile "C:\ProgramData\Contoso\Assets\logo.bmp" -Model "Surface Pro 7" -Manufacturer "Microsoft"

    .LINK
    https://www.tenforums.com/tutorials/76570-customize-oem-support-information-windows-10-a.html
    
    .NOTES
    General notes
    #>
    param (
        [Parameter()]
        [String]
        $LogoFile,
        [Parameter(ParameterSetName='Vendor',Mandatory=$true)]
        [String]
        $Manufacturer,
        [Parameter(ParameterSetName='Vendor',Mandatory=$true)]
        [String]
        $Model,
        [Parameter(ParameterSetName='Support',Mandatory=$false)]
        [String]
        $SupportHours,
        [Parameter(ParameterSetName='Support',Mandatory=$true)]
        [String]
        $SupportPhone,
        [Parameter(ParameterSetName='Support',Mandatory=$true)]
        [String]
        $SupportURL
    )
    
    # Set the logo on the support page
    if(($LogoFile -ne "") -and (Test-Path $LogoFile) -and ([IO.Path]::GetExtension($LogoFile) -eq ".bmp")){
        New-ItemProperty -Force -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "Logo" -Value $LogoFile
    }

    # Variables for the hardware information queried from WMI if no parameters are specified
    [String]$_manufacturer = $(Get-WMIObject -Query "SELECT Manufacturer FROM Win32_ComputerSystem").Manufacturer.Trim("");
    [String]$_model = $(Get-WMIObject -Query "SELECT Model FROM Win32_ComputerSystem").Model.Trim("");

    # Set the hardware information variables to values passed from the function call
    if (($Manufacturer -ne "") -and ($Model -ne "")) {
        $_manufacturer = $Manufacturer
        $_model = $Model
    }

    # Actually set the values in the registry
    New-ItemProperty -Force -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "Model" -Value $_model 
    New-ItemProperty -Force -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "Manufacturer" -Value $_manufacturer

    #Verify that support information has been provided, then set the information
    if(($SupportPhone -ne "") -and ($SupportURL -ne "")){
        # #Add Support information to Registry
        New-ItemProperty -Force -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "SupportHours" -Value $SupportHours
        New-ItemProperty -Force -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "SupportPhone" -Value $SupportPhone
        New-ItemProperty -Force -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "SupportURL" -Value $SupportURL
    }

}