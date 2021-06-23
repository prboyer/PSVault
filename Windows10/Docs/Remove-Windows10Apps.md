---
Author: Paul Boyer
external help file: PSVault-Windows10-help.xml
Module Guid: ffa4f42e-7097-4055-ae7d-e2e8974c6758
Module Name: PSVault-Windows10
online version:
schema: 2.0.0
---

# Remove-Windows10Apps

## SYNOPSIS
Script for removing Windows 10 metro apps.

## SYNTAX

```
Remove-Windows10Apps [[-Version] <Int32>] [[-AppListName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Provided an update version or a specific AppList name, the script will remove applications that prevent the system from being syspreped for imaging.

## EXAMPLES

### EXAMPLE 1
```
Remove-Windows10Apps -Version 1909
```

### EXAMPLE 2
```
Remove-Windows10Apps -AppListName "AllApps"
```

## PARAMETERS

### -Version
Integer parameter representing the feature version of the OS.
Check "winver" for the version number.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppListName
String parameter representing the name of a specific AppList to remove from the system

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
Paul Boyer - Last updated 2-11-2021

## RELATED LINKS
