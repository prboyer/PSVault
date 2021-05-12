---
Author: Paul Boyer
external help file: PSVault-Office365-help.xml
Module Guid: f6f83d86-3ee4-4f1c-b9e9-8dca9c20819b
Module Name: PSVault-Office365
online version:
schema: 2.0.0
---

# Get-O365ServicingChannel

## SYNOPSIS
Script to quickly determine what Office 365 servicing channel a PC is subscribed to

## SYNTAX

```
Get-O365ServicingChannel [-Quiet] [<CommonParameters>]
```

## DESCRIPTION
Script checks the local machine's registry key for Office 365 CDNUrl against the strings for either the Annual or Monthly channels and returns feedback

## EXAMPLES

### EXAMPLE 1
```
Get-O365ServicingChannel
```

## PARAMETERS

### -Quiet
Parameter suppresses the GUI message box and limits output to just the console

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
Date: 3-22-21

## RELATED LINKS
