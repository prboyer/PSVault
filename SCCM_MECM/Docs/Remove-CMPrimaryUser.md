---
Author: Paul Boyer
external help file: psvault-SCCM_MECM-help.xml
Module Guid: bed21bd1-6f2c-4c2d-b1b8-4cd7271806ad
Module Name: psvault-SCCM_MECM
online version:
schema: 2.0.0
---

# Remove-CMPrimaryUser

## SYNOPSIS
A script to remove user device affinity associations from devices in SCCM for a given user

## SYNTAX

```
Remove-CMPrimaryUser [-Users] <String[]> [[-Computers] <String[]>] [[-Domain] <String>] [<CommonParameters>]
```

## DESCRIPTION
The script will remove a given user's device affinity associations from SCCM from all machines, or if a parameter is passed
the device affinity will be removed for a user on specific machines.

## EXAMPLES

### EXAMPLE 1
```
Remove-CMPrimaryUser -Username "Contoso\BillG","Contoso\SteveB"
```

### EXAMPLE 2
```
Remove-CMPrimaryUser -Username "BillG" -Computers "server01" -Domain "Fabrikam"
```

## PARAMETERS

### -Users
A String array of usernames.
These can be either fully-qualified usernames (Contoso\BillG) or just sAM Account Names (Bill G).
Multiple usernames can be passed

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computers
A String array of computer names.
These need not be fully-qualified.
The parameter can accept multiple computer names.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Domain
The NetBIOS name of the domain.
The script will implicitly grab the NetBIOS name from the current domain unless another is passed at runtime.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Paul B.
10-28-2019

## RELATED LINKS
