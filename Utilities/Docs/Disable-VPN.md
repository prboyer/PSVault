---
Author: Paul Boyer
external help file: psvault-Utilities-help.xml
Module Guid: 0ba23f80-06be-4ccc-a218-05969d5e5b5e
Module Name: psvault-Utilities
online version:
schema: 2.0.0
---

# Disable-VPN

## SYNOPSIS
Disables a VPN connection given the appropriate environmental criteria is met.

## SYNTAX

```
Disable-VPN [-WiFi] [<CommonParameters>]
```

## DESCRIPTION
Checks if the PC is connected to Ethernet, and if the IP address is on the right LAN.
If both conditions are met, the VPN is disabled (optionally Wi-Fi turned off too).

## EXAMPLES

### EXAMPLE 1
```
Disable-VPN
```

Disables the VPN connection.

### EXAMPLE 2
```
Disable-VPN -WiFi
```

Disables the VPN connection and turns off Wi-Fi.

## PARAMETERS

### -WiFi
Switch to disable Wi-Fi.

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
Date: 07-07-2021

## RELATED LINKS
