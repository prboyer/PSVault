# function Export-MDReadMe {
#     [CmdletBinding()]
#     param (
#         [Parameter()]
#         [String]
#         $ModuleDir,
#         [String]
#         $OutputDir,
#         [switch]
#         $Concat
#     )
    
#     #######################
#     # Assign parameter to working variable in the script
#     [String]$Path = $ModuleDir

#     # Move the scripts to their own folder
#     New-Item -Path $Path -Name "Scripts" -ItemType Directory -Force
#     Get-ChildItem -Path $Path -Filter "*.ps1" | Move-Item -Destination "$Path\Scripts"

#     $Path = "$Path\Scripts"

#     # Get all the PS1 files in the directory
#     $files = Get-ChildItem -Path $Path -Filter "*.ps1"

#     # Append the contents of all the PS1 files into a PSM1 module file
#     if ($Concat) {
#         $files | %{
#             Get-Content -Path $_.FullName | Out-File -FilePath "$ModuleDir\PSVault-$(Split-Path -Path $Path -Leaf).psm1" -Append -Force
#         }
#     }else {
#         # Dot source all the PS1 files in a PSM1 module file
#         $files | %{
#             [string]$(". `"$Path\"+$_.Name+"`"") | Out-File -FilePath "$ModuleDir\PSVault-$(Split-Path -Path $Path -Leaf).psm1" -Append -Force 
#         }
#     }

#     # Get the full path to the newly created module
#     [String]$moduleFullName = $(Get-ChildItem -Path $ModuleDir -Filter "*.psm1").FullName

#     # Get the module name
#     [String]$moduleName = $(Get-ChildItem -Path $ModuleDir -Filter "*.psm1").Name
   
#     Import-Module -Name $moduleFullName -DisableNameChecking -Force

#     # Import the markdown generation module, platyPS
#     Import-Module platyPS

#     if ($OutputDir -ne "") {
#         [String]$OutputFolder = $OutputDir
#     }else {
#         [String]$OutputFolder = $ModuleDir
#     }
    
    
#     $CreateMDParameters = @{
#         Module = $moduleName.Remove($moduleName.Length-5,5)
#         OutputFolder = $OutputFolder
#         AlphabeticParamsOrder = $true
#         WithModulePage = $false
#         ExcludeDontShow = $true
#     }
#     New-MarkdownHelp @CreateMDParameters


#     $UpdateMDParameters = @{
#         Path = $OutputFolder
#         RefreshModulePage = $true
#         UpdateInputOutput = $false
#         ExcludeDontShow = $true
#     }
#     Update-MarkdownHelpModule @UpdateMDParameters

#     Move-Item -Path $($OutputFolder+"\"+$moduleName.Remove($moduleName.Length-5,5)+".md") -Destination $((Split-Path -Path $OutputFolder -Parent)+"\README.md")

#     Update-MarkdownHelp -Path $Path 
# }

# Export-MDReadMe -ModuleDir "$PSScriptRoot\Utilities" -OutputDir "$PSScriptRoot\Utilities\docs"  #-SubDir "Public" 

function Export-ReadMe {
    param (
        [String]
        $Path,
        [Switch]
        $Concat
    )

    # Import platyPS
    Import-Module -Name platyPS

    # Get all the PS1 files in the directory
    $files = Get-ChildItem -Path $Path -Filter "*.ps1"

    # Append the contents of all the PS1 files into a PSM1 module file
    if ($Concat) {
        $files | %{
            Get-Content -Path $_.FullName | Out-File -FilePath "$Path\PSVault-$(Split-Path -Path $Path -Leaf).psm1" -Append -Force
        }
    }else {
        # Dot source all the PS1 files in a PSM1 module file
        $files | %{
            [string]$(". `"$Path\"+$_.Name+"`"") | Out-File -FilePath "$Path\PSVault-$(Split-Path -Path $Path -Leaf).psm1" -Append -Force 
        }
    }

    # Import the module file
    $moduleFile = Get-ChildItem -Path $Path -Filter "*.psm1"
    Import-Module -Name $($Path+"\"+$moduleFile.BaseName) -DisableNameChecking

    # Generate platyPS markdown
    $parameters= @{
        Module = $moduleFile.BaseName
        FwLink = "https://github.com/prboyer/PSVault"
        Metadata = @{Author = "Paul Boyer"; 'Module Guid'= $(New-Guid).Guid; }
        Locale = "en-US"
        ExcludeDontShow = $true
        HelpVersion = "1.0.1"
        OutputFolder = "$Path\docs"
        Force = $true
        WithModulePage = $true
        ModulePagePath ="$Path\README.md"
    }

    New-MarkdownHelp @parameters

    
    
}
Export-ReadMe -Path "$PSScriptRoot\ActiveDirectory"