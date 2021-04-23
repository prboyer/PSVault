---
Author: Paul Boyer
external help file:
Module Guid: 2e905317-62e7-4b00-bc0e-a8039e418e68
Module Name: PSVault-Windows10
online version:
schema: 2.0.0
---

# Set-TLSVersion

## SYNOPSIS
Short script to set the Security Protocol

## SYNTAX

```
Set-TLSVersion [-Version] <String> [-Registry] [<CommonParameters>]
```

## DESCRIPTION
Using the .NET methods, the script sets the Security Protocol to the value passed by -Version parameter

## EXAMPLES

### EXAMPLE 1
```
Set-TLSVersion -Version Tls12
```

## PARAMETERS

### -Version
String for the Security Protocol that should be set

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Registry
Parameter description

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
Date: 4-14-21

## RELATED LINKS

[https://www.eshlomo.us/check-and-update-powershell-tls-version/](https://www.eshlomo.us/check-and-update-powershell-tls-version/)

