function Get-UserDirectories{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName="ComputerNames")]
        [String[]]
        $ComputerNames,
        [Parameter(Mandatory=$true,ParameterSetName="Local")]
        [Switch]
        $Local,
        [Parameter(ParameterSetName="ComputerNames")]
        [Parameter(ParameterSetName="Local")]
        [String[]]
        $Exclude

    )
    #requires -Modules ActiveDirectory

    # Directories to exclude
    [String[]]$EXCLUDED_DIRS = @("Public")

    # Add additional directories to exclude at runtime
    if ($Exclude -ne "") {
        [String[]]$Exclusions = $EXCLUDED_DIRS + $Exclude
    }else{
        [String[]]$Exclusions = $EXCLUDED_DIRS
    }

    # If -Local is supplied, get the directories from the local machine
    if ($Local) {
         # get user directories from the local machine
        $localDirs = Get-ChildItem -Path "C:\Users" -Exclude $Exclusions

        # create a new object array to store the custom objects
        [PSObject[]]$objects = @(

            # create a custom object for each local user directory and then match it to an AD user
            $localDirs | %{
                    [PSCustomObject]@{
                    Name = (Get-ADUser $_.Name).Name
                    Username = (Get-ADUser $_.Name).SamAccountName
                    User_Directory = $_.FullName
                    };
            }
        )

        return $objects

    }else{
        # foreach($C in $ComputerNames){
        #     try {
        #         $comp = Get-ADComputer $C
        #     }
        #     catch {
        #         Write-Error $("Unable to connect to {0}" -f $C) 
        #     }

        #     # get user directories from the remote machine
        #     $remoteDirs = Get-Item -Path $("\\"+$comp.DNSHostName+"\c$\Users") | Get-ChildItem -Exclude $Exclusions

        #     # additional logic to strip out excluded directories
        #     $remoteDirs = $remoteDirs | ?{$_ -notin $Exclusions}
            
        #     $remoteDirs 
            
        #  }
        # return $compObjects
    }
}


#TODO Get remote directory listing working properly

Get-UserDirectories -ComputerNames "Tomahawk","Wintermute"












# #Variables

# #CSV list of users
# #$importFile = 'C:\Users\pboyer2\Desktop\Missing Workstations2.csv'

# #exlcusions list
# $exclusions = @('hdadmin','administrator','Public','housing\hdadmin','housing\administrator','Admin','Admin1','admini~1');

# #output file
# #$outFile = 'C:\Users\pboyer2\Desktop\Missing Workstations Data.xlsx'

# $workstations = Get-ADComputer -Filter * | Select Name

# #############################
# #Install-Module -Name ImportExcel

# $illegalSuffix = @('.old','.Housing');

# #$numLines = Import-Csv $importFile | Measure-Object | Select Count

# #$workstations = @();

# #$file = Import-Csv $importFile

# #for($i=0; $i -ilt $numLines.Count; $i++){
#  #   $workstations += $file[$i].Asset;
# #}

# $table = New-Object System.Data.DataTable

# $col1 = New-Object system.Data.DataColumn Computer,([String])
# $col2 = New-Object system.Data.DataColumn NetID,([String])
# $col3 = New-Object system.Data.DataColumn Name,([String])
# $col4 = New-Object system.Data.DataColumn Department,([String])

# $table.columns.add($col1)
# $table.columns.add($col2)
# $table.columns.add($col3)
# $table.columns.add($col4)

# foreach($workstation in $workstations){
    
  
#     Set-Location -Path "\\$workstation\c$\users" -ErrorAction SilentlyContinue
   

#     $numUsers = Get-ChildItem | Measure-Object | Select Count

#     $users = Get-ChildItem

#     for($m = 0; $m -ilt $numUsers.Count; $m++){
#         if($users[$m].Name -inotin $exclusions -and $users[$m].Name -notlike '*.old' -and $users[$m].Name -notlike '*.housing'){

#         $row = $table.NewRow();

#         $row.Computer = $workstation;
        
#         $row.NetID = $users[$m].Name

#         $row.Name = (Get-ADUser $users[$m].Name -ErrorAction SilentlyContinue).Name

#         $row.Department = (Get-ADUser $users[$m].Name -ErrorAction SilentlyContinue).DistinguishedName 

#         $table.Rows.Add($row);

#     }

# }


# }

# $table | Format-Table -AutoSize

#$table | Export-Excel -Path $outFile
        