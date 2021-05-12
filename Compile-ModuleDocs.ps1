function Compile-ModuleDocs {
    param (
        [Parameter()]
        [String]
        $Path,
        [Parameter()]
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
           # Find the Readme file from listing all files in the current directory ($D)
           $ReadMe = Get-ChildItem -Path $D.FullName -Recurse -File | Where-Object{$_.Name -eq "README.md"}
            
           # Get the content of the Readme file. Perform validation first before trying to get the content
           try{
                if (Test-Path -Path $ReadMe.FullName) {
                    $Content = Get-Content -Path $ReadMe.FullName | Select-Object -Skip 7
            }
           }catch{
               # Throw a non-terminating warning if a Readme file cannot be located
               Write-Warning -Message $("Unable to resolve path to README file in {0}" -f $D)
           }
           
            # Change the path of the link in the readme file to be resolvable from the front page
            $ModifiedContent = $Content | %{
                if ($_ -like "### *") {
                    $_.Insert($_.IndexOf('(')+1,"$D/")
                }else{
                    $_
                }
            }

            # Add the content to the holding variable
            $CompiledData += $ModifiedContent
        }

    <# Write out the new README file for the frontpage #>
        $Title | Out-String| Out-File -FilePath $OutFile
        $Description | Out-String | Out-File -FilePath $OutFile -Append
        $ImageCode | Out-String | Out-File -FilePath $OutFile -Append
        $CompiledData | Out-String | Out-File -FilePath $OutFile -Append

}