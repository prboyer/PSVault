---
Author: Paul Boyer
external help file: psvault-Windows11-help.xml
Module Guid: 4b53e073-5b6c-4244-b7f7-0c33a961e74c
Module Name: psvault-Windows11
online version:
schema: 2.0.0
---

# Set-Win11TaskbarPosition

## SYNOPSIS
Script that sets the position of the Windows 11 taskbar.

## SYNTAX

```
Set-Win11TaskbarPosition [-Left] [-Center] [<CommonParameters>]
```

## DESCRIPTION
Manipulate the position of the Windows 11 taskbar by modifying the registry key in HKCU.

## EXAMPLES

### EXAMPLE 1
```
Set-Win11TaskbarPosition -Left
```

Sets the taskbar to be aligned to the left.

## PARAMETERS

### -Left
Parameter that causes the script to position the taskbar aligned to the left

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

### -Center
Parameter that causes the script to position the taskbar aligned center.

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
Author: Paul Boyer
Date: 6-28-2021

## RELATED LINKS

[https://www.bleepingcomputer.com/news/microsoft/new-windows-11-registry-hacks-to-customize-your-device/](https://www.bleepingcomputer.com/news/microsoft/new-windows-11-registry-hacks-to-customize-your-device/)

