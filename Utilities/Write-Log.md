---
external help file: PSVault-Public-help.xml
Module Name: PSVault-Public
online version: https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0
schema: 2.0.0
---

# Write-Log

## SYNOPSIS
Write-Log writes a message to a specified log file with the current time stamp.

## SYNTAX

```
Write-Log [-Message] <String> [[-Path] <String>] [[-Level] <String>] [-NoClobber] [<CommonParameters>]
```

## DESCRIPTION
The Write-Log function is designed to add logging capability to other scripts.
In addition to writing output and/or verbose you can write to a log file for
later debugging.

## EXAMPLES

### EXAMPLE 1
```
Write-Log -Message 'Log message'
```

Writes the message to c:\Logs\PowerShellLog.log.

### EXAMPLE 2
```
Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log
```

Writes the content to the specified log file and creates the path and file specified.

### EXAMPLE 3
```
Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
```

Writes the message to the specified log file as an error message, and writes the message to the error pipeline.

## PARAMETERS

### -Level
Specify the criticality of the log information being written to the log (i.e.
Error, Warning, Informational)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Info
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
Message is the content that you wish to add to the log file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: LogContent

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NoClobber
Use NoClobber if you do not wish to overwrite an existing file.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
The path to the log file to which you would like to write.
By default the function will 
create the path and file if it does not exist.

```yaml
Type: String
Parameter Sets: (All)
Aliases: LogPath

Required: False
Position: 2
Default value: C:\Logs\PowerShellLog.log
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Created by: Jason Wasser @wasserja
Modified: 11/24/2015 09:30:19 AM  

Changelog:
 * Code simplification and clarification - thanks to @juneb_get_help
 * Added documentation.
 * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks
 * Revised the Force switch to work as it should - thanks to @JeffHicks

To Do:
 * Add error handling if trying to create a log file in a inaccessible location.
 * Add ability to write $Message to $Verbose or $Error pipelines to eliminate
   duplicates.

## RELATED LINKS

[https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0](https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0)

