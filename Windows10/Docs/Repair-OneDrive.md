---
Author: Paul Boyer
external help file: psvault-Windows10-help.xml
Module Guid: 365380a9-8cef-470f-9396-9f684904d499
Module Name: psvault-Windows10
online version:
schema: 2.0.0
---

# Repair-OneDrive

## SYNOPSIS
Script to repair Microsoft OneDrive if it is no longer working properly.

## SYNTAX

```
Repair-OneDrive [-Uninstall] [<CommonParameters>]
```

## DESCRIPTION
Script manipulates registry to fix key that is preventing normal functionality.
Additionally, OneDrive can be removed using the -Uninstall parameter

## EXAMPLES

### EXAMPLE 1
```
Repair-OneDrive
```

## PARAMETERS

### -Uninstall
Causes the script to remove the OneDrive program from the PC

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
Date: 3-24-21

## RELATED LINKS

[https://answers.microsoft.com/en-us/msoffice/forum/msoffice_onedrivefb-mso_win10-mso_o365b/onedrive-will-not-start/687028ae-2d32-4783-ba28-2cf050e32670](https://answers.microsoft.com/en-us/msoffice/forum/msoffice_onedrivefb-mso_win10-mso_o365b/onedrive-will-not-start/687028ae-2d32-4783-ba28-2cf050e32670)

[https://www.winhelponline.com/blog/reset-onedrive-windows-10/](https://www.winhelponline.com/blog/reset-onedrive-windows-10/)

