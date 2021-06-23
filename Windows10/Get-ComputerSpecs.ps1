function Get-ComputerSpecs{
    <#
    .SYNOPSIS
        Script to create a report of a machine's hardware.
    .DESCRIPTION
        The script uses mainly WMI to query the hardware (and OS) of a machine and generate a text report. The report can then be saved to a location specified by -Path. The script can be run
        against remote machines by supplying a value for -ComputerName.
    .EXAMPLE
        PS C:\> Get-ComputerSpecs -Path C:\temp\report.txt
        Run the report and save the results to a TXT file at C:\temp\report.txt

    .EXAMPLE
        PS C:\> Get-ComputerSpecs -Path C:\temp\report.txt -ComputerName Server01.contoso.com
        Run the report against Server01.contoso.com and save the results to a TXT file at C:\temp\report.txt

    .OUTPUTS
        .TXT file containing the hardware report for the computer.
    .NOTES
        Author: Paul Boyer
        Date: 06-23-2021
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        # Confirm $Path is Valid
        [ValidateScript({Test-Path -Path $_ -IsValid -PathType Leaf})]
        [String]
        $Path,
        [Parameter()]
        [String]
        $ComputerName
    )
    <# Process input for ComputerName #>       
        if($ComputerName -eq ""){
            $ComputerName = $env:COMPUTERNAME
        }

    <# Create variable to hold output from Information stream #>
        [String]$INFO

    <# Get Storage Information #>
        [String]$Storage = "Storage`n*******"
        
        Write-Host  $Storage -ForegroundColor Magenta
        
        Write-Information $Storage -InformationVariable +INFO

        # Create a table with attributes of physical disks on the system, using the Get-PhysicalDisk cmdlet
        [Object[]]$StorageTable;

        if($ComputerName -ne $env:COMPUTERNAME){
            $StorageTable = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Get-PhysicalDisk | Select-Object Number,FriendlyName,MediaType,Size,HealthStatus
            }
        }else{
            $StorageTable = Get-PhysicalDisk | Select-Object Number,FriendlyName,MediaType,Size,HealthStatus
        }
        
        Write-Information -MessageData $($StorageTable | Format-Table -AutoSize | Out-String) -InformationVariable +INFO -InformationAction Continue

    <# Get Memory Information #>
        [String]$Memory = "Memory`n******"

        Write-Host $Memory -ForegroundColor Cyan

        Write-Information $Memory -InformationVariable +INFO

        # Create a table of attributes about system RAM using WMI query
        [Object[]]$DIMMS = Get-WmiObject -Class "win32_PhysicalMemory" -namespace "root\CIMV2" -ComputerName $ComputerName

        # Perform manipulation of the table elements using calculated properties
        $DIMMS = $DIMMS | Select-Object @{Name='DIMM Slot';expression={$_.DeviceLocator}},@{Name="Memory Size (GB)";expression={$_.Capacity / 1GB}}

        Write-Information ("Total Number of DIMM Slots: {0}" -f $(Get-WmiObject -Class "win32_PhysicalMemoryArray" -namespace "root\CIMV2").MemoryDevices) -InformationVariable +INFO -InformationAction Continue

        Write-Information ("Total RAM: {0} GB" -f $($DIMMS | Measure-Object -Property 'Memory Size (GB)' -Sum).Sum) -InformationVariable +INFO -InformationAction Continue

        Write-Information -MessageData $($DIMMS | Format-Table -AutoSize |Out-String) -InformationVariable +INFO -InformationAction Continue

    <# Get Processor Information #>
        [String]$Processor = "Processor`n*********"

        Write-Host $Processor -ForegroundColor Yellow

        Write-Information $Processor -InformationVariable +INFO 

        # Get information about the system's CPUs from the Win32_Processor WMU class
        [Object[]]$ProcessorTable = Get-WmiObject -Class Win32_Processor -ComputerName $ComputerName | Select-Object DeviceID,Name,Caption,NumberOfCores,NumberOfLogicalProcessors

        Write-Information ("Total Number of CPUs: {0}" -f $($ProcessorTable | Measure-Object -Property DeviceID).Count) -InformationVariable +INFO -InformationAction Continue

        Write-Information ("Total Number of Physical Cores: {0}" -f $($ProcessorTable | Measure-Object -Property NumberOfCores -Sum).Sum) -InformationVariable +INFO -InformationAction Continue

        Write-Information ("Total Number of Logical Cores: {0}" -f $($ProcessorTable | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum) -InformationVariable +INFO -InformationAction Continue

        Write-Information $($ProcessorTable |Format-Table -AutoSize | Out-String) -InformationVariable +INFO

    <# Operating System and other Info #>
        # Perform queries to WMI to gather information about the system and operating system
        [Object[]]$OperatingSystemTable = Get-WmiObject -Query "SELECT * FROM win32_operatingsystem" -ComputerName $ComputerName | Select-Object CSName,Caption,BuildNumber,OSArchitecture,Manufacturer,SystemDrive,SystemDirectory
        [Object[]]$ComputerSystemTable = Get-WmiObject -Query "SELECT * FROM win32_computersystem" -ComputerName $ComputerName | Select-Object Name,BootupState,Caption,Domain,Manufacturer,Model,SystemSKUNumber,SystemType
        [Object[]]$SystemEnclosureTable = Get-WmiObject -Query "SELECT * FROM win32_systemenclosure" -ComputerName $ComputerName | Select-Object SerialNumber

        [String]$OperatingSystem = "`nOperating System`n****************"
        
        Write-Host $OperatingSystem -ForegroundColor Blue

        Write-Information -MessageData $OperatingSystem -InformationVariable +INFO
        
        # Use calculated properties to manipulate the table and the write it out
        Write-Information ($OperatingSystemTable | Select-Object @{Name="ComputerName";expression={$_.CSName}},Caption,OSArchitecture,BuildNumber,SystemDrive,SystemDirectory | Format-Table -AutoSize | Out-String) -InformationAction Continue -InformationVariable +INFO

        [String]$ComputerSystem = "Computer System`n***************"
        
        Write-Host $ComputerSystem -ForegroundColor Green
        
        Write-Information -MessageData $ComputerSystem -InformationVariable +INFO

        # Use calculated property to merge in data from another WMI query. Then write out the table.
        Write-Information ($ComputerSystemTable | Select-Object Name,Domain,Manufacturer,Model,@{Name="SerialNumber";Expression={$SystemEnclosureTable.SerialNumber}},SystemSKUNumber,SystemType | Format-Table -AutoSize | Out-String) -InformationAction Continue -InformationVariable +INFO

    <# Write out the file to $Path #>
        Out-File -FilePath $Path -Force -InputObject $INFO
}