---
Author: Paul Boyer
external help file: psvault-Utilities-help.xml
Module Guid: 0ba23f80-06be-4ccc-a218-05969d5e5b5e
Module Name: psvault-Utilities
online version:
schema: 2.0.0
---

# Query-Users

## SYNOPSIS
PowerShell implementation of quser.exe

## SYNTAX

```
Query-Users [-ShowIndicator] [<CommonParameters>]
```

## DESCRIPTION
Returns a table of logged on users, and the logon time as a a workable PowerShell Custom Object \[System.Management.Automation.PSCustomObject\]

## EXAMPLES

### EXAMPLE 1
```
Query-Users
```

### EXAMPLE 2
```
Query-Users -ShowIndicator
```

## PARAMETERS

### -ShowIndicator
Switch parameter to print the logged on user indicator in the table

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
Paul Boyer 2-23-21

## RELATED LINKS

[https://stackoverflow.com/questions/39212183/easier-way-to-parse-query-user-in-powershell](https://stackoverflow.com/questions/39212183/easier-way-to-parse-query-user-in-powershell)

[https://ss64.com/nt/query-user.html](https://ss64.com/nt/query-user.html)

