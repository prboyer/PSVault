---
Author: Paul Boyer
external help file: psvault-Utilities-help.xml
Module Guid: 0ba23f80-06be-4ccc-a218-05969d5e5b5e
Module Name: psvault-Utilities
online version:
schema: 2.0.0
---

# Import-FromFile

## SYNOPSIS
Script to standardize importing lists from files.

## SYNTAX

### Text
```
Import-FromFile -TXT <String> [-HeaderRows <Int32>] [<CommonParameters>]
```

### Excel
```
Import-FromFile [-HeaderRows <Int32>] [-Column <Int32>] -XLS <String> [-WorkbookName <String>]
 [<CommonParameters>]
```

### CSV
```
Import-FromFile [-Header <Int32>] [-Column <Int32>] -CSV <String> [<CommonParameters>]
```

## DESCRIPTION
The script will take in either at TXT, CSV, or Excel list and process it for use in Powershell.
Using
parameters, headers can be stripped from the files as necessary.

## EXAMPLES

### EXAMPLE 1
```
Import-FromFile -TXT C:\Temp\list.txt
```

## PARAMETERS

### -TXT
Path to a *.txt file to process

```yaml
Type: String
Parameter Sets: Text
Aliases: Text

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HeaderRows
Int representing the number of rows to remove from the top of the file

```yaml
Type: Int32
Parameter Sets: Text, Excel
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Header
Int representing the row number of the header

```yaml
Type: Int32
Parameter Sets: CSV
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Column
If the file is multidimenstional, the Column integer tells the script what range to process

```yaml
Type: Int32
Parameter Sets: Excel, CSV
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -CSV
Path to .csv file

```yaml
Type: String
Parameter Sets: CSV
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -XLS
Path to .xls or .xlsx file

```yaml
Type: String
Parameter Sets: Excel
Aliases: Excel, XLSX

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkbookName
The name of the Workbook in the Excel file.
Only necessary if different than the default "Sheet1".

```yaml
Type: String
Parameter Sets: Excel
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### A .txt, .csv, or .xls(x) file.
## OUTPUTS

### A string array
## NOTES
Paul Boyer 2-25-21

## RELATED LINKS
