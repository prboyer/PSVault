---
Author: Paul Boyer
external help file: psvault-ActiveDirectory-help.xml
Module Guid: 66f0b290-a051-4b8e-be84-b0a280c74a50
Module Name: psvault-ActiveDirectory
online version:
schema: 2.0.0
---

# Compare-ADGroupMembership

## SYNOPSIS
A script for comparing two Active Directory users' group membership.

## SYNTAX

```
Compare-ADGroupMembership [-ReferenceUser] <String> [-DifferenceUser] <String> [[-OutFile] <String>]
 [-IncludeBoth] [<CommonParameters>]
```

## DESCRIPTION
The script grabs the group membership of two Active Directory users and compares them.
Then optionally writes the output to a file.
Additionally, the script can show similar groups between the users.

## EXAMPLES

### EXAMPLE 1
```
Compare-ADGroupMembership -ReferenceUser "jdoe" -DifferenceUser "jsmith" -OutFile "C:\Users\jdoe\Desktop\GroupMembership.txt"
```

## PARAMETERS

### -ReferenceUser
The username of the user whose group membership is to be compared as the left operand.

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

### -DifferenceUser
The username of the user whose group membership is to be compared as the right operand.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile
Optional path to write the output to a file

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

### -IncludeBoth
Switch that will cause the script show similar groups between the users

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
Date: 11-2-2021

## RELATED LINKS
