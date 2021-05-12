---
Author: Paul Boyer
external help file: PSVault-Office365-help.xml
Module Guid: f6f83d86-3ee4-4f1c-b9e9-8dca9c20819b
Module Name: PSVault-Office365
online version:
schema: 2.0.0
---

# Repair-O365Click2Run

## SYNOPSIS
Script that calls the O365 ClickToRun executable with the appropriate parameters for a repair.

## SYNTAX

```
Repair-O365Click2Run [[-Path] <String>] [-Force] [-Quiet] [-OnlineRepair] [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
Repair-O365Click2Run -Force -OnlineRepair
```

## PARAMETERS

### -Path
String path to the Click2Run executable if not stored in the default location

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

### -Force
Switch parameter to force all O365 apps to close before running the repair process

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

### -Quiet
Switch parameter to suppress the ClickToRun executable UI

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

### -OnlineRepair
Switch parameter indicating that a more exhaustive Online Repair should be performed

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

## RELATED LINKS

[https://forums.ivanti.com/servlet/fileField?entityId=ka14O000000Xhh0&field=File_attachment__Body__s](https://forums.ivanti.com/servlet/fileField?entityId=ka14O000000Xhh0&field=File_attachment__Body__s)

[https://www.thewindowsclub.com/repair-microsoft-365-using-command-prompt](https://www.thewindowsclub.com/repair-microsoft-365-using-command-prompt)

