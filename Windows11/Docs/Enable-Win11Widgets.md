---
Author: Paul Boyer
external help file: PSVault-Windows11-help.xml
Module Guid: af74b2ec-963d-4219-a6e6-1e561723f92f
Module Name: PSVault-Windows11
online version:
schema: 2.0.0
---

# Enable-Win11Widgets

## SYNOPSIS
Script to enable or disable the Widgets panel in Windows 11

## SYNTAX

```
Enable-Win11Widgets [-Disable] [<CommonParameters>]
```

## DESCRIPTION
Enable or disable the Widgets panel by modifying the registry key in HKCU.
Running the script with no parameter will enable the panel.

## EXAMPLES

### EXAMPLE 1
```
Enable-Win11Widgets -Disable
```

Disable the Windows 11 Widgets panel

## PARAMETERS

### -Disable
Parameter that causes the script to disable the Widgets panel in Windows 11.

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

