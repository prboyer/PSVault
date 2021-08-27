function Get-ComputerSpecs{
    <#
    .SYNOPSIS
        A PowerShell script to create a report of a machine's hardware.
    .DESCRIPTION
        The script uses mainly WMI to query the hardware (and OS) of a machine and generate a text report. The report can then be saved to a location specified by -Path. The script can be run
        against remote machines by supplying a value for -ComputerName.
    .PARAMETER Path
        A file path to to a .txt file to save the report to.

    .PARAMETER ComputerName
        The name of the computer to query. If not specified, the local machine is queried.

    .EXAMPLE
        Get-ComputerSpecs -Path C:\temp\report.txt
        Run the report and save the results to a TXT file at C:\temp\report.txt

    .EXAMPLE
        Get-ComputerSpecs -Path C:\temp\report.txt -ComputerName Server01.contoso.com
        Run the report against Server01.contoso.com and save the results to a TXT file at C:\temp\report.txt

    .OUTPUTS
        A .TXT file containing the hardware report for the computer.

    .INPUTS
        A single name, or list of names, of the computer(s) to query.

    .NOTES
        Author: Paul Boyer
        Date: 06-23-2021
    #>
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript({if((Test-Path -Path $_ -IsValid -PathType Leaf) -and ([System.IO.File]::GetExtension($_.Path) -eq '.txt')){return $true}})]
        [String]
        $Path,
        [Parameter()]
        [String[]]
        $ComputerName
    )
    <# Create variable to hold output from Information stream #>
        [String]$INFO;

    <# Process input for ComputerName. If no value is passed, then query the local machine by default.  #>
        if($ComputerName -eq "" -or $null -eq $ComputerName){
            $ComputerName = $env:COMPUTERNAME
        }
    
    # Iterate through the list of computer names and query each one.
    $ComputerName | ForEach-Object{
        <# Write the name of the computer to the report file #>
        Write-Information "`n-------------------------------------------------------------------`r" -InformationAction Continue -InformationVariable +INFO
        Write-Information "`t`t`t   $($_.ToUpper())" -InformationAction Continue -InformationVariable +INFO
        Write-Information "`r-------------------------------------------------------------------`n" -InformationAction Continue  -InformationVariable +INFO

        <# Get Storage Information #>
            [String]$Storage = "Storage`n*******"

            Write-Host  $Storage -ForegroundColor Magenta

            Write-Information $Storage -InformationVariable +INFO

            # Create a table with attributes of physical disks on the system, using the Get-PhysicalDisk cmdlet
            [Object[]]$StorageTable;

            if($_ -ne $env:COMPUTERNAME){
                $StorageTable = Invoke-Command -ComputerName $_ -ScriptBlock {
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
            [Object[]]$DIMMS = Get-WmiObject -Class "win32_PhysicalMemory" -namespace "root\CIMV2" -ComputerName $_

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
            [Object[]]$ProcessorTable = Get-WmiObject -Class Win32_Processor -ComputerName $_ | Select-Object DeviceID,Name,Caption,NumberOfCores,NumberOfLogicalProcessors

            Write-Information ("Total Number of CPUs: {0}" -f $($ProcessorTable | Measure-Object -Property DeviceID).Count) -InformationVariable +INFO -InformationAction Continue

            Write-Information ("Total Number of Physical Cores: {0}" -f $($ProcessorTable | Measure-Object -Property NumberOfCores -Sum).Sum) -InformationVariable +INFO -InformationAction Continue

            Write-Information ("Total Number of Logical Cores: {0}" -f $($ProcessorTable | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum) -InformationVariable +INFO -InformationAction Continue

            Write-Information $($ProcessorTable |Format-Table -AutoSize | Out-String) -InformationVariable +INFO

        <# Operating System and other Info #>
            # Perform queries to WMI to gather information about the system and operating system
            [Object[]]$OperatingSystemTable = Get-WmiObject -Query "SELECT * FROM win32_operatingsystem" -ComputerName $_ | Select-Object CSName,Caption,BuildNumber,OSArchitecture,Manufacturer,SystemDrive,SystemDirectory
            [Object[]]$ComputerSystemTable = Get-WmiObject -Query "SELECT * FROM win32_computersystem" -ComputerName $_ | Select-Object Name,BootupState,Caption,Domain,Manufacturer,Model,SystemSKUNumber,SystemType
            [Object[]]$SystemEnclosureTable = Get-WmiObject -Query "SELECT * FROM win32_systemenclosure" -ComputerName $_ | Select-Object SerialNumber

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
        if ($Path -ne "") {
            Out-File -FilePath $Path -Force -InputObject $INFO -Append
        }
    }
}