---
Author: Paul Boyer
external help file: PSVault-Windows10-help.xml
Module Guid: ca000c27-bbbd-4774-9eca-516ab4c061c0
Module Name: PSVault-Windows10
online version: https://www.eshlomo.us/check-and-update-powershell-tls-version/
schema: 2.0.0
---

# Remove-UpdateAssistant

## SYNOPSIS
Script to remove the Windows 10 Upgrade Assistant

## SYNTAX

```
Remove-UpdateAssistant [[-Reboot] <ParameterAttribute>] [<CommonParameters>]
```

## DESCRIPTION
Script tries to uninstall the Windows 10 Upgrade Assistant if it is detected on the system.
Then it removes the assistant's working files and optionally reboots to
complete the cleanup.

## EXAMPLES

### EXAMPLE 1
```
Remove-UpdateAssistant
```

### EXAMPLE 2
```
Remove-UpdateAssistant -Reboot
```

## PARAMETERS

### -Reboot
Switch parameter to indicate a reboot should be performed after the script finishes uninstalling and cleaning up the update assistant

```yaml
Type: ParameterAttribute
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Paul Boyer 2-11-2021

## RELATED LINKS
