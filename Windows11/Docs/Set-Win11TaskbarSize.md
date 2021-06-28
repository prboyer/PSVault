---
Author: Paul Boyer
external help file: PSVault-Windows11-help.xml
Module Guid: af74b2ec-963d-4219-a6e6-1e561723f92f
Module Name: PSVault-Windows11
online version:
schema: 2.0.0
---

# Set-Win11TaskbarSize

## SYNOPSIS
Script used to set the Windows 11 Taskbar Size

## SYNTAX

### Small
```
Set-Win11TaskbarSize [-Small] [<CommonParameters>]
```

### Medium
```
Set-Win11TaskbarSize [-Medium] [<CommonParameters>]
```

### Large
```
Set-Win11TaskbarSize [-Large] [<CommonParameters>]
```

## DESCRIPTION
The script can be called with three different arguments (Small, Medium, Large).
If no parameter is passed, the taskbar is reverted to the default Windows 11 size (Medium)

## EXAMPLES

### EXAMPLE 1
```
Set-Win11TaskbarSize -Large
```

Sets the Windows Taskbar size to large.

## PARAMETERS

### -Small
Parameter that causes the script to set the taskbar size to Small

```yaml
Type: SwitchParameter
Parameter Sets: Small
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Medium
Parameter that causes the script to set the taskbar size to Medium

```yaml
Type: SwitchParameter
Parameter Sets: Medium
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Large
Parameter that causes the script to set the taskbar size to Large

```yaml
Type: SwitchParameter
Parameter Sets: Large
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

