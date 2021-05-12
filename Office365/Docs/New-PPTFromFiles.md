---
Author: Paul Boyer
external help file: PSVault-Office365-help.xml
Module Guid: f6f83d86-3ee4-4f1c-b9e9-8dca9c20819b
Module Name: PSVault-Office365
online version:
schema: 2.0.0
---

# New-PPTFromFiles

## SYNOPSIS
Quickly create a PowerPoint presentation from a folder full of files (like screenshots)

## SYNTAX

```
New-PPTFromFiles [-Folder] <String> [[-FileType] <String>] [<CommonParameters>]
```

## DESCRIPTION
After validating that folder path exists, and that the extension has been passed in the appropriate format, get the contents
of the directory and copy/paste each file into a new PowerPoint presentation.

## EXAMPLES

### EXAMPLE 1
```
New-PPTFromFiles -Folder "C:\Temp\Pictures" -FileType ".png"
```

## PARAMETERS

### -Folder
Path to folder containing files to import into the PowerPoint presentation

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileType
String to specify the extension of files in the folder to import with or without the leading '.'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Paul Boyer 2-17-21

## RELATED LINKS

[https://devblogs.microsoft.com/scripting/hey-scripting-guy-can-i-add-a-new-slide-to-an-existing-microsoft-powerpoint-presentation/](https://devblogs.microsoft.com/scripting/hey-scripting-guy-can-i-add-a-new-slide-to-an-existing-microsoft-powerpoint-presentation/)

[https://stackoverflow.com/questions/33847434/how-can-i-create-a-new-powerpoint-presentation-with-powershell/33850587](https://stackoverflow.com/questions/33847434/how-can-i-create-a-new-powerpoint-presentation-with-powershell/33850587)

