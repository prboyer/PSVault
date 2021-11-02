---
Author: Paul Boyer
external help file: psvault-Windows11-help.xml
Module Guid: 4b53e073-5b6c-4244-b7f7-0c33a961e74c
Module Name: psvault-Windows11
online version:
schema: 2.0.0
---

# Set-Win11StartMenu

## SYNOPSIS
Script to modify the appearance of the Windows 11 Start Menu.

## SYNTAX

```
Set-Win11StartMenu [-Win10Style] [<CommonParameters>]
```

## DESCRIPTION
The script modifies a registry key in HKCU to change the appearance of the Start Menu.

## EXAMPLES

### EXAMPLE 1
```
Set-Win11StartMenu -Win10Style
```

Sets the Start Menu to the Windows 10 style.

### EXAMPLE 2
```
Set-Win11StartMenu
```

Restores the Start Menu back to the original Windows 11 style.

## PARAMETERS

### -Win10Style
Passing the Win10Style parameter will revert the Start Menu to its previous style.
Omitting the parameter on a subsequent run will reset it to the Windows 11 style

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

