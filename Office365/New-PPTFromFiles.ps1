function New-PPTFromFiles {
    <#
    .SYNOPSIS
    Quickly create a PowerPoint presentation from a folder full of files (like screenshots)

    .DESCRIPTION
    After validating that folder path exists, and that the extension has been passed in the appropriate format, get the contents
    of the directory and copy/paste each file into a new PowerPoint presentation.

    .PARAMETER Folder
    Path to folder containing files to import into the PowerPoint presentation

    .PARAMETER FileType
    String to specify the extension of files in the folder to import with or without the leading '.'

    .EXAMPLE
    New-PPTFromFiles -Folder "C:\Temp\Pictures" -FileType ".png"

    .LINK
    https://devblogs.microsoft.com/scripting/hey-scripting-guy-can-i-add-a-new-slide-to-an-existing-microsoft-powerpoint-presentation/

    .LINK
    https://stackoverflow.com/questions/33847434/how-can-i-create-a-new-powerpoint-presentation-with-powershell/33850587

    .NOTES
    Paul Boyer 2-17-21
    #>
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType 'Container'})]
        [String]
        $Folder,
        [Parameter(Mandatory=$false)]
        # Validate that either an extension starting with '.' is passed, or just the extension name
        [ValidateScript({($_ -match "^\." -and $_.length -eq 4) -or $test.length -eq 3})]
        [String]
        $FileType
    )
    # Add required types and assemblies
    Add-type -AssemblyName office
    Add-type -AssemblyName microsoft.office.interop.powerpoint
    [Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null;
    [Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null;

    # Create the PowerPoint application object, and make the application visible.
    $Application = New-Object -ComObject powerpoint.application
    $application.visible = [Microsoft.Office.Core.MsoTriState]::msoTrue

    # Set the slide ype & layout
    $slideType = "microsoft.office.interop.powerpoint.ppSlideLayout" -as [type]
    $layout = $slideType::ppLayoutBlank

    # create new presentation
    $presentation = $application.Presentations.add()

    # declare variable for filter
    [String]$Filter;

    # check if an extension or type was provided
    if($FileType -match "^\."){
        $Filter = "*$FileType"
    }else{
        $Filter = "*.$FileType"
    }

    Write-Host $("Adding {0} files from `"{1}`" to new PowerPoint Presentation" -f $(Get-ChildItem $Folder | Measure-Object).Count, $(Get-Item -Path $Folder).FullName)

    Get-ChildItem -Path $Folder -File -Filter $Filter | Sort-Object -Property LastWriteTime | ForEach-Object{
        # add slide
        $slide = $presentation.slides.add(1,$layout)

        # get the file, and copy to the clipboard
        $file = get-item -Path $_.FullName
        $img = [System.Drawing.Image]::Fromfile($file);
        [System.Windows.Forms.Clipboard]::SetImage($img);

        Start-Sleep -Seconds 1

        # paste the file into the powerpoint presentation
        $shape = $Slide.Shapes.PasteSpecial($ppPasteShape,$false,$null,$null,$null,$null)

        Start-Sleep -Seconds 1
    }

    Write-Host "Complete" -ForegroundColor Green
}