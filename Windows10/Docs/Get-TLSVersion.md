---
Author: Paul Boyer
external help file: psvault-Windows10-help.xml
Module Guid: 365380a9-8cef-470f-9396-9f684904d499
Module Name: psvault-Windows10
online version:
schema: 2.0.0
---

# Get-TLSVersion

## SYNOPSIS
Short script that returns the current TLS version settings

## SYNTAX

```
Get-TLSVersion [<CommonParameters>]
```

## DESCRIPTION
Script uses .NET methods to get the current TLS version settings.
Then prints out results to console.
Also returns current setting as a string.

## EXAMPLES

### EXAMPLE 1
```
Get-TLSVersion
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### String with current system setting for connection security.
## NOTES
Author: Paul Boyer
Date: 4-14-21

## RELATED LINKS

[https://www.eshlomo.us/check-and-update-powershell-tls-version/](https://www.eshlomo.us/check-and-update-powershell-tls-version/)

