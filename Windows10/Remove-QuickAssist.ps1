function Remove-QuickAssist{
    <#
    .SYNOPSIS
    Simple function wrapper for removing Windows QuickAssist

    .DESCRIPTION
    Removes the Windows Quick Assist app using the Remove-WindowsCapability cmdlet

    .EXAMPLE
    Remove-QuickAssist

    .NOTES
        Author: Paul Boyer
        Date: 5-11-21
    #>

    Remove-WindowsCapability -Online -Name "App.Support.QuickAssist*" -Verbose

}