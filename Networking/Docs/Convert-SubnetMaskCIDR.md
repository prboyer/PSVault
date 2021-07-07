---
Author: Paul Boyer
external help file: PSVaultNetworking-help.xml
Module Guid: 3bbe10b9-2f91-4569-9736-19d802abb414
Module Name: PSVaultNetworking
online version:
schema: 2.0.0
---

# Convert-SubnetMaskCIDR

## SYNOPSIS
Converts a subnet mask to a CIDR notation

## SYNTAX

```
Convert-SubnetMaskCIDR [[-SubnetMask] <String>] [<CommonParameters>]
```

## DESCRIPTION
Converts a subnet mask to a CIDR notation by first converting the subnet mask to a binary string.
Then it summaries the binary string and converts the summaries to a CIDR notation.

## EXAMPLES

### EXAMPLE 1
```
Convert-SubnetMaskCIDR 255.255.255.0
```

Converts 255.255.255.0 to CIDR notation (/24)

## PARAMETERS

### -SubnetMask
The subnet mask to convert.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Paul Boyer
Date: 07-07-2021

https://docs.netgate.com/pfsense/en/latest/network/cidr.html

## RELATED LINKS
