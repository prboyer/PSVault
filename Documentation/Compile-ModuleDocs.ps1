function Compile-ModuleDocs {
    <#
    .SYNOPSIS
    Script that updates the README file on the front page.
    
    .DESCRIPTION
    Script pulls data from the individual README files in each folder and consolidates them into one README for the front page. Script
    also changes the paths in the consolidated file so that they can be resolved from the front page.
    
    .PARAMETER Path
    Path to working directory containing sub-folders with scripts and README files. 

    .PARAMETER OutFile
    Path to where the consolidated file should be saved.
    
    .EXAMPLE
   Compile-ModuleDocs -Path C:\Scripts -OutFile C:\Scripts\Readme.md
    
    .NOTES
        Author: Paul Boyer
        Date: 5-12-21
    #>
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            # Validation script requires that a file path be passed and it must be a MD file. 
            if(($_ -ne "") -and ([System.IO.Path]::GetExtension($_) -eq ".md")){
                return $true;
            }else{
                return $false;
            }
        })]
        [String]
        $OutFile
    )

    <# Variables #>
        <# Define the heading of the frontpage README file.#>
            # The title of the frontpage file
            [String]$Title = "# PowerShell Vault"

            # The description immediately following the title
            [String]$Description = "A Refined Collection of PowerShell Scripts"
            
            # HTML code for adding in the image. 
            [String]$ImageCode = @'
<p align="center">
    <img src="ps_vault.svg" alt="Logo for PSVault. Attribution to SVG Repo https://www.svgrepo.com/svg/217127/vault" width="400" height="400">
</p>
'@
        <# Variable that holds the contents of each individual README file #>
            [String]$CompiledData
    
    <# Traverse through each folder in -Path and find the README file. Then copy its contents to the consolidated file#>
        # Get a directory listing of all folders in $Path
        [Object[]]$Directories = Get-ChildItem -Path $Path -Directory
        
        # For each directory, get the readme file and do some string manipulation
        foreach ($D in $Directories) {
            $D

           # Find the Readme file from listing all files in the current directory ($D)
           $ReadMe = Get-ChildItem -Path $D.FullName -Recurse -File | Where-Object{$_.Name -eq "README.md"}

           # Get the content of the Readme file. Perform validation first before trying to get the content
           try{
                if (Test-Path -Path $ReadMe.FullName) {
                    $Content = Get-Content -Path $ReadMe.FullName | Select-Object -Skip 7

                    # Change the path of the link in the readme file to be resolvable from the front page
                    $ModifiedContent = $Content | ForEach-Object{
                        if ($_ -like "### *") {
                            $_.Insert($_.IndexOf('(')+1,"$D/")
                        }else{
                            $_
                        }
                    }

                    # Change the H1 Headings to be links
                    $ModCont = $ModifiedContent | ForEach-Object{
                        if (($_ -match "^\#.\w")) {
                            $Header = $_.Insert(2,"[")
                            $Header = $Header.Insert($Header.Length,"]($D/README.md)")
                            # $Header = $Header.Insert($Header.Length,$($_.TrimStart('# ')))
                            $Header
                        }else{
                            $_
                        }
                    }

                    # Add the content to the holding variable
                    $CompiledData += $ModCont

                    # Add a <hr> between modules
                    $CompiledData += "`n<hr>`n"
                }    
           }catch{
               # Throw a non-terminating warning if a Readme file cannot be located
               Write-Warning -Message $("Unable to resolve path to README file in {0}" -f $D)
           }
        }

    <# Write out the new README file for the frontpage #>
        $Title | Out-String| Out-File -FilePath $OutFile
        $Description | Out-String | Out-File -FilePath $OutFile -Append
        $ImageCode | Out-String | Out-File -FilePath $OutFile -Append
        $CompiledData | Out-String | Out-File -FilePath $OutFile -Append

}