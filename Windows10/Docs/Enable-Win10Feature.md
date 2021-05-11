---
Author: Paul Boyer
external help file: PSVault-Windows10-help.xml
Module Guid: 061148c6-e723-4e1d-a021-b5780f4333f5
Module Name: PSVault-Windows10
online version:
schema: 2.0.0
---

# Enable-Win10Feature

## SYNOPSIS
Script to re-enable Windows 10 features that were removed due to / resulting from image capture issues.

## SYNTAX

```
Enable-Win10Feature [-Calculator] [-StickyNotes] [<CommonParameters>]
```

## DESCRIPTION
Script searches for AppXManifest files in the WindowsApps directory of the system and attempts to register the manifest files for missing Windows 10 feature.

## EXAMPLES

### EXAMPLE 1
```
Enable-Win10Feature -Calculator
```

## PARAMETERS

### -Calculator
Switch parameter indicating that the script should try to re-register the calculator

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

### -StickyNotes
Switch parameter indicating that the script should try to re-register sticky notes

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
Paul Boyer 1-26-18

## RELATED LINKS
