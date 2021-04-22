---
Author: Paul Boyer
external help file: PSVault-Windows10-help.xml
Module Guid: 0bbca885-5304-447b-8c88-49e1ea49c43d
Module Name: PSVault-Windows10
online version: http://www.tenforums.com/tutorials/14312-windows-photo-viewer-restore-windows-10-a.html
schema: 2.0.0
---

# Enable-WindowsPhotoViewer

## SYNOPSIS
A simple script to re-enable the legacy Windows Photo Viewer

## SYNTAX

```
Enable-WindowsPhotoViewer [[-Path] <String>] [-NoAdd] [<CommonParameters>]
```

## DESCRIPTION
The script exports pre-formatted text to a registry key that is then merged with the system registry by the script (unless parameter is passed to prevent merging)

## EXAMPLES

### EXAMPLE 1
```
Enable-WindowsPhotoViewer -NoAdd
```

## PARAMETERS

### -Path
Alternate location that the registry key will be exported to.
Otherwise $env:TEMP is used

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoAdd
Switch parameter that prevents the key from being merged into the registry

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Paul Boyer 2-22-21

## RELATED LINKS

[http://www.tenforums.com/tutorials/14312-windows-photo-viewer-restore-windows-10-a.html](http://www.tenforums.com/tutorials/14312-windows-photo-viewer-restore-windows-10-a.html)

