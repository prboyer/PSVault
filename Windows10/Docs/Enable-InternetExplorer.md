---
Author: Paul Boyer
external help file: PSVault-Windows10-help.xml
Module Guid: ffa4f42e-7097-4055-ae7d-e2e8974c6758
Module Name: PSVault-Windows10
online version:
schema: 2.0.0
---

# Enable-InternetExplorer

## SYNOPSIS
Short script to add back Internet Explorer after it is not longer functioning.

## SYNTAX

```
Enable-InternetExplorer [-SetupFiles] <ValidateNotNullOrEmptyAttribute> [<CommonParameters>]
```

## DESCRIPTION
Script runs DISM with a path to Windows setup files and repairs the package for Internet Explorer.

## EXAMPLES

### EXAMPLE 1
```
Enable-InternetExplorer -SetupFiles C:\Win10Setup.iso
```

## PARAMETERS

### -SetupFiles
Path to either a Windows 10 ISO, or an extracted directory of setup files.
This should be a path to the root.

```yaml
Type: ValidateNotNullOrEmptyAttribute
Parameter Sets: (All)
Aliases:

Required: True
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

## RELATED LINKS
