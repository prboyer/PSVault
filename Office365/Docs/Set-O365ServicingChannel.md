---
Author: Paul Boyer
external help file: PSVault-Office365-help.xml
Module Guid: f6f83d86-3ee4-4f1c-b9e9-8dca9c20819b
Module Name: PSVault-Office365
online version:
schema: 2.0.0
---

# Set-O365ServicingChannel

## SYNOPSIS
A quick and handy script for modifying the Windows Registry to switch the Office 365 servicing channel.

## SYNTAX

```
Set-O365ServicingChannel [-Monthly] [-UseRegistry] [<CommonParameters>]
```

## DESCRIPTION
The script switches Office 365 applications between monthly and semi-annual servicing channels by either using the Office C2R client or manipulating the 
appropriate registry key in the HKLM hive.
By default, the script will set the local machine to the semi-annual servicing channel.

## EXAMPLES

### EXAMPLE 1
```
Change-O365ServicingChannel -Monthly
```

## PARAMETERS

### -Monthly
Switch parameter that changes the default behavior of the script.
Causes the servicing channel to be set to Monthly, rather than Semi Annual.

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

### -UseRegistry
Switch parameter that forces the script to use the registry to update the servicing channel rather than the Office C2R client.

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
Author: Paul Boyer - 1-29-2021

## RELATED LINKS

[https://docs.microsoft.com/en-us/deployoffice/overview-update-channels](https://docs.microsoft.com/en-us/deployoffice/overview-update-channels)

[https://www.solver.com/switching-office-365-monthly-update-channel](https://www.solver.com/switching-office-365-monthly-update-channel)

[https://windowstechpro.com/switch-office-365-semi-channel-to-monthly-targeted-channel/](https://windowstechpro.com/switch-office-365-semi-channel-to-monthly-targeted-channel/)

