function Remove-QuickAssist{
    <#
    .SYNOPSIS
    Script removes Windows QuickAssist functionality
    
    .DESCRIPTION
    Removes the Windows Quick Assist app using the Remove-WindowsCapability cmdlet
    
    .EXAMPLE
    Remove-QuickAssist

    .NOTES
    
    #>


    Remove-WindowsCapability -Online -Name "App.Support.QuickAssist*" -Verbose
}