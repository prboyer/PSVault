---
Author: Paul Boyer
external help file: PSVault-Windows10-help.xml
Module Guid: e3d92bd8-c4a3-4bc8-bb7d-c1d573ced30b
Module Name: PSVault-Windows10
online version:
schema: 2.0.0
---

# Set-SystemInformation

## SYNOPSIS
Script to update the manufacturer information from the System Control Panel page

## SYNTAX

### Vendor
```
Set-SystemInformation [-LogoFile <String>] -Manufacturer <String> -Model <String> [<CommonParameters>]
```

### Support
```
Set-SystemInformation [-LogoFile <String>] [-SupportHours <String>] -SupportPhone <String> -SupportURL <String>
 [<CommonParameters>]
```

## DESCRIPTION
The OEM (Original Equipment Manufacturer) support information in Windows includes the logo, manufacturer, model, support hours, support phone, and support URL for your PC

## EXAMPLES

### EXAMPLE 1
```
Set-SystemInformation -LogoFile "C:\ProgramData\Contoso\Assets\logo.bmp" -Model "Surface Pro 7" -Manufacturer "Microsoft"
```

## PARAMETERS

### -LogoFile
String filepath to *.bmp logo file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Manufacturer
String name of the manufacturer to override the value from WMI

```yaml
Type: String
Parameter Sets: Vendor
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Model
String name of the model to override the value from WMI

```yaml
Type: String
Parameter Sets: Vendor
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SupportHours
String indicating the help desk's support hours

```yaml
Type: String
Parameter Sets: Support
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SupportPhone
String indicating the help desk's phone number

```yaml
Type: String
Parameter Sets: Support
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SupportURL
String indicating the help desk's website or web portal

```yaml
Type: String
Parameter Sets: Support
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS

[https://www.tenforums.com/tutorials/76570-customize-oem-support-information-windows-10-a.html](https://www.tenforums.com/tutorials/76570-customize-oem-support-information-windows-10-a.html)

