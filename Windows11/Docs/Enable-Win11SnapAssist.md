---
Author: Paul Boyer
external help file: psvault-Windows11-help.xml
Module Guid: 4b53e073-5b6c-4244-b7f7-0c33a961e74c
Module Name: psvault-Windows11
online version:
schema: 2.0.0
---

# Enable-Win11SnapAssist

## SYNOPSIS
Script to enable or disable Windows 11 Snap Assist functionality.

## SYNTAX

```
Enable-Win11SnapAssist [-Disable] [<CommonParameters>]
```

## DESCRIPTION
Enable or disable the Snap Assist functionality by modifying the registry key in HKCU.
Running the script with no parameter re-enables Snap Assist

## EXAMPLES

### EXAMPLE 1
```
Enable-Win11SnapAssist -Disable
```

Disable Snap Assist

## PARAMETERS

### -Disable
Parameter that causes the script to disable the Snap Assist functionality

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

[https://www.pcworld.com/article/3622022/windows-11-start-menu-how-to-make-it-look-like-windows-10.html](https://www.pcworld.com/article/3622022/windows-11-start-menu-how-to-make-it-look-like-windows-10.html)

