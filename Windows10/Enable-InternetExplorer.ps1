function Enable-InternetExplorer {
    <#
    .SYNOPSIS
    Short script to add back Internet Explorer after it is not longer functioning.
    
    .DESCRIPTION
    Script runs DISM with a path to Windows setup files and repairs the package for Internet Explorer.
    
    .PARAMETER SetupFiles
    Path to either a Windows 10 ISO, or an extracted directory of setup files. This should be a path to the root.
    
    .EXAMPLE
    Enable-InternetExplorer -SetupFiles C:\Win10Setup.iso
    
    .NOTES
   
    #>
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty]
        [String]
        $SetupFiles
    )

    # variable used in the DISM call to the Windows setup files
    [String]$Path;

    # variable for the actual name of the package supplied to DISM
    [String]$Package = "sources\sxs\microsoft-windows-internetexplorer-optional-package.cab"

    # flag to indicate if disk image needs to be dismounted at end of script
    [bool]$Flag = $false;
    
    # check if the provided path to the setup files is to an image file
    if([IO.Path]::GetExtension($SetupFile) -eq ".iso"){
        try{
            Get-DiskImage -ImagePath $SetupFiles | Mount-DiskImage -StorageType ISO -Access ReadOnly
        }catch{
            Write-Error "There was an error mounting the disk image you specified. {0}" -f $SetupFiles
        }

        $Flag = $true;

        $Path = $(Get-DiskImage -ImagePath $SetupFiles | Get-Volume).DriveLetter+":";
    }else{
        $Path = $SetupFiles
    }

    # run the DISM command to add back Internet Explorer
    Start-Process -FilePath DISM.exe -ArgumentList "/Online /Add-Package /PackagePath:$Path\$Package" -NoNewWindow -Wait

    # finally unmount the disk image if flag was set
    if($Flag){
        Dismount-DiskImage -ImagePath $SetupFiles
    }
    
}