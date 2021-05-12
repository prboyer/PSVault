<#
.SYNOPSIS
Script that runs a report against your AD instance to query for escrowed Bitlocker recovery keys.

.DESCRIPTION
The script can be used to generate a report of computers in your AD domain that have had their
Bitlocker recovery keys escrowed to AD. The report can be modified (with parameters) to show data for only machines with 
missing keys and can also write out the results to a CSV.

.PARAMETER SearchBase
The DistinguishedName of the starting point for the search. You can enter the DN of an OU or just the root of the domain to
search for all machines

.PARAMETER All
"All" will return results for all machines, whether there is an escrowed key or not. By default, the report only returns
results for machines with keys (null keys are excluded).

.PARAMETER NoKey
Only returns a list of machines with null recovery keys.

.PARAMETER FilePath
The filepath where the CSV file should be saved. Validation in script confirms that filepath is passed with .CSV extension.

.EXAMPLE
Get-BitlockerKey -SearchBase "DC=corp,DC=contoso,DC=com" -FilePath "C:\BitlockerReport.csv"

.NOTES
	Author: Paul Boyer
	Date: 7-7-2020

Script adopted from https://social.technet.microsoft.com/Forums/en-US/fbb2135e-e3ce-4eb0-8ddc-ff9f3d0b0158/ad-objects-without-bitlocker-keys-stored-in-ad?forum=winserverDS

#>
function Get-BitlockerKey{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[String]
		$SearchBase,
		[switch]
		$All,
		[switch]
		$NoKey,
		[String]
		[ValidateScript({[System.IO.Path]::GetExtension($_) -eq ".csv"})]
		$FilePath
	)
	
	# ArrayList declaration to hold the list of custom objects
	[System.Collections.ArrayList]$ObjectArray = @();

	# Variables stores a list of computers returned from the $SearchBase
	$computers = Get-ADComputer -Filter 'ObjectClass -eq "Computer"' -SearchBase $SearchBase

	# Traverse the list and get the computername,distinghuishedname, and bitlockerpassword for each member of the array, then add to array list
	foreach ($x in $computers){
		$psObject = New-Object -TypeName psobject

		$psObject | Add-Member -MemberType NoteProperty -Name ComputerName -Value $x.Name;
		$psObject | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value $x.DistinguishedName;
		$psObject | Add-Member -MemberType NoteProperty -Name BitlockerPassword -Value (Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $x.DistinguishedName -Properties 'msFVE-RecoveryPassword' | Select-Object -Last 1).'msFVE-RecoveryPassword'
		$o = $ObjectArray.Add($psObject)
	}

	# enter if block when there is a path specified for the results to be written to a CSV
	if($FilePath -ne "" -and $FilePath -ne $null){
		# Print out all results for computers in the arraylist
		# Print out list of computers without key
		if($NoKey){
			$ObjectArray.ToArray() | Where-Object {$_.BitlockerPassword -eq $null} | Sort-Object -Property ComputerName | Select-Object ComputerName, BitlockerPassword | Export-CSV -Path $FilePath -NoClobber -Force
		}

		# Print out list of computers with key
		else{
			$ObjectArray.ToArray() | Where-Object {$_.BitlockerPassword -ne $null} | Sort-Object -Property ComputerName | Select-Object ComputerName, BitlockerPassword | Export-CSV -Path $FilePath -NoClobber -Force
		}
	}
	else{
		# Print out all results for computers in the arraylist
		if ($All) {
			$ObjectArray.ToArray() | Select-Object ComputerName,BitlockerPassword | Sort-Object -Property ComputerName | Format-Table
		}

		# Print out list of computers without key
		elseif($NoKey){
			$ObjectArray.ToArray() | Where-Object {$_.BitlockerPassword -eq $null} | Sort-Object -Property ComputerName | Select-Object ComputerName, BitlockerPassword
		}

		# Print out list of computers with key
		else{
			$ObjectArray.ToArray() | Where-Object {$_.BitlockerPassword -ne $null} | Sort-Object -Property ComputerName | Select-Object ComputerName, BitlockerPassword
		}
	}
}