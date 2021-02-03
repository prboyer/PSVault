---
external help file: psvault-Office365-help.xml
Module Name: psvault-Office365
online version: https://docs.microsoft.com/en-us/deployoffice/overview-update-channels
schema: 2.0.0
---

# Set-O365ServicingChannel

## SYNOPSIS
A quick and handy script for modifying the Windows Registry to switch the Office 365 servicing channel.

## SYNTAX

```
Set-O365ServicingChannel [-Monthly]
```

## DESCRIPTION
The script switches Office 365 applications between monthly and semi-annual servicing channels by manipulating the 
appropriate registry key in the HKLM hive.
By default, the script will set the local machine to the semi-annual servicing channel.
By using the -Monthly parameter, the servicing channel will be updated.

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

## INPUTS

## OUTPUTS

## NOTES
Author: Paul Boyer - 1-29-2021

## RELATED LINKS

[https://docs.microsoft.com/en-us/deployoffice/overview-update-channels](https://docs.microsoft.com/en-us/deployoffice/overview-update-channels)

[https://www.solver.com/switching-office-365-monthly-update-channel](https://www.solver.com/switching-office-365-monthly-update-channel)

