function Get-ComputerDriveSpecs {
    <#
    .SYNOPSIS
    Determine the non-volatile drive specs of the computer and if an upgrade is necessary. 
    
    .DESCRIPTION
    Evaluates the non-volatile drive specs of the computer and if an upgrade is necessary. If the machine has a HDD or if the current drive is over-utilized (too full, not enough capacity) then a upgrade recommendation is made.
    
    .PARAMETER ComputerNames
    String array of computer names to check the disk specs of. If not specified, the current computer is checked.
    
    .PARAMETER OutFile
    A location to save a report of the disk specs. If not specified, the report is written to the console.
    
    .EXAMPLE
    Get-ComputerDriveSpecs -ComputerNames "server1 server2" -OutFile "c:\temp\drivespecs.txt"

    Returns a report of the disk specs of the specified computers and writes the results to 'drivespecs.txt'.

    .EXAMPLE
    Get-ComputerDriveSpecs 

    Returns a report of the disk specs of the current computer.    
    
    .NOTES
        Author: Paul Boyer
        Date: 11-5-2021
    #>
    param (
        [Parameter()]
        [string[]]
        $ComputerNames,
        [Parameter()]
        [ValidateScript({if(Test-Path -Path ($_ | Split-Path -Parent) -PathType Container){return $true}else{return $false}})]
        [String]
        $OutFile
    )
    # Variable to hold information for the output file
    [String]$global:LOG

    # Variable to hold the upgrade utilization capacity threshold. Drives with utilization greater than this percentage will advised to move up to a larger capacity
    [Double]$UpgradeUtilizationThreshold = 60

    # Test if the script needs to be run remotely or just against the local machine
    if ($ComputerNames -eq $null){
        
        Write-Information ("~~~ {0} ~~~" -f $env:COMPUTERNAME.ToString().ToUpper()) -InformationAction  Continue -InformationVariable +LOG
        
        Write-Information "Get Disk Utilization & Upgrade Recommendation`n" -InformationAction  Continue -InformationVariable +LOG

        # Get information about the phsyical disk
        Write-Information "System Disk Information" -InformationAction  Continue -InformationVariable +LOG
        [Object]$Disk = Get-Disk | Where-Object {$_.IsSystem -eq $true -and $_.IsBoot -eq $true} | Select-Object FriendlyName,BusType,@{Name="MediaType";Expression={(Get-PhysicalDisk -SerialNumber $_.SerialNumber).MediaType}},PartitionStyle,HealthStatus,@{Name="Total Size (GB)";Expression={[Math]::round($_.Size / [Math]::Pow(1000,3),2)}}

        Write-Information ($Disk | Format-Table -AutoSize | Out-String) -InformationAction  Continue -InformationVariable +LOG

        # Get information about the Windows system partition
        Write-Information "System Partition Information`n" -InformationAction  Continue -InformationVariable +LOG
        [Object]$Volume = Get-Volume | Where-Object {$_.FileSystemLabel -eq "Windows" -or $_.FileSystemLabel -eq "OSDisk"}

        # Write out an Ascii progress bar to display utilization
        [Int]$barwidth = 50
        [Double]$percentfill = [Math]::round(($Volume.SizeRemaining / $Volume.Size)*100,2)
        Write-Information $("Utilization [{0}{1}] {2}%" -f ('='*(($percentfill/100)*$barwidth)), ("-"*((1-($percentfill/100))*$barwidth)),$percentfill) -InformationAction  Continue -InformationVariable +LOG

        Write-Information ($Volume | Format-Table -AutoSize | Out-String) -InformationAction  Continue -InformationVariable +LOG

        # Make an upgrade recommendation based on the disk and partition information
        Write-Information "Upgrade Recommendation" -InformationAction  Continue -InformationVariable +LOG
        if ($Disk.MediaType -ne "SSD" -and $percentfill -gt $UpgradeUtilizationThreshold) {
            Write-Host ("`tRecommendation: Upgrade to {0} GB SSD" -f ($Disk.'Total Size (GB)' * 2)) -ForegroundColor Yellow -InformationAction  Continue -InformationVariable +LOG
        }elseif($Disk.MediaType -ne "SSD"){
            Write-Host ("`tRecommendation: Upgrade to {0} GB SSD" -f ($Disk.'Total Size (GB)')) -ForegroundColor Yellow -InformationAction  Continue -InformationVariable +LOG
        }elseif($percentfill -gt $UpgradeUtilizationThreshold){
            Write-Host ("`tRecommendation: Upgrade from {0} GB SSD to {1} GB SSD" -f ($Disk.'Total Size (GB)'),($Disk.'Total Size (GB)' * 2)) -ForegroundColor Yellow -InformationAction  Continue -InformationVariable +LOG
        }
        else{
            Write-Host ("`tRecommendation: No upgrade required") -ForegroundColor Green -InformationAction  Continue -InformationVariable +LOG
        }
    }
    else{
        # Loop through each computer name and get the drive information
        $ComputerNames | ForEach-Object {
            Invoke-Command -ComputerName $_ -ArgumentList $_,$UpgradeUtilizationThreshold -ScriptBlock {
                Write-Information ("~~~ {0} ~~~" -f $args[0].ToString().ToUpper()) -InformationAction  Continue -InformationVariable +LOG

                Write-Information "Get Disk Utilization & Upgrade Recommendation`n" -InformationAction  Continue -InformationVariable +LOG

                # Get information about the phsyical disk
                Write-Information "System Disk Information" -InformationAction  Continue -InformationVariable +LOG
                [Object]$Disk = Get-Disk | Where-Object {$_.IsSystem -eq $true -and $_.IsBoot -eq $true} | Select-Object FriendlyName,BusType,@{Name="MediaType";Expression={(Get-PhysicalDisk -SerialNumber $_.SerialNumber).MediaType}},PartitionStyle,HealthStatus,@{Name="Total Size (GB)";Expression={[Math]::round($_.Size / [Math]::Pow(1000,3),2)}}

                Write-Information ($Disk | Format-Table -AutoSize | Out-String) -InformationAction  Continue -InformationVariable +LOG

                # Get information about the Windows system partition
                Write-Information "System Partition Information`n" -InformationAction  Continue -InformationVariable +LOG
                [Object]$Volume = Get-Volume | Where-Object {$_.FileSystemLabel -eq "Windows" -or $_.FileSystemLabel -eq "OSDisk"}

                # Write out an Ascii progress bar to display utilization
                [Int]$barwidth = 50
                [Double]$percentfill = [Math]::round(($Volume.SizeRemaining / $Volume.Size)*100,2)
                Write-Information $("Utilization [{0}{1}] {2}%" -f ('='*(($percentfill/100)*$barwidth)), ("-"*((1-($percentfill/100))*$barwidth)),$percentfill) -InformationAction  Continue -InformationVariable +LOG

                Write-Information ($Volume | Format-Table -AutoSize | Out-String) -InformationAction  Continue -InformationVariable +LOG

                # Make an upgrade recommendation based on the disk and partition information
                Write-Information "Upgrade Recommendation" -InformationAction  Continue -InformationVariable +LOG
                if ($Disk.MediaType -ne "SSD" -and $percentfill -gt $args[1]) {
                    Write-Host ("`tRecommendation: Upgrade from HDD to {0} GB SSD" -f ($Disk.'Total Size (GB)' * 2)) -ForegroundColor Yellow -InformationAction  Continue -InformationVariable +LOG
                }elseif($Disk.MediaType -ne "SSD"){
                    Write-Host ("`tRecommendation: Upgrade from HDD to {0} GB SSD" -f ($Disk.'Total Size (GB)')) -ForegroundColor Yellow -InformationAction  Continue -InformationVariable +LOG
                }elseif($percentfill -gt $args[1]){
                    Write-Host ("`tRecommendation: Upgrade from {0} GB SSD to {1} GB SSD" -f ($Disk.'Total Size (GB)'),($Disk.'Total Size (GB)' * 2)) -ForegroundColor Yellow -InformationAction  Continue -InformationVariable +LOG
                }else{
                    Write-Host ("`tRecommendation: No upgrade required") -ForegroundColor Green -InformationAction  Continue -InformationVariable +LOG
                }
            } -AsJob -JobName $_ | Out-Null; Wait-Job $_; Receive-Job $_ -InformationVariable +LOG
        }
    }
    
    # Write the output to a file
    if ($OutFile -ne ""){
        $LOG | Out-File -FilePath $OutFile -Encoding ASCII
    }
}