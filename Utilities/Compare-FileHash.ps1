function Compare-FileHash {
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $DifferenceDirectory,
        [Parameter(Mandatory=$true)]
        [String]
        $ReferenceDirectory,
        [Parameter()]
        [Switch]
        $NoHelp,
        [Parameter()]
        [String]
        $Algorithim,
        [Parameter]
        [switch]
        $Recurse,
        [Parameter()]
        [String]
        $Path
    )

    # Determine the comparison algorithm. Default is MD5
    [String]$Algo = "MD5"
    if($Algorithim -ne ""){
        $Algo = $Algorithim;
    }

    # Check the hashes of the files in each directory
    if($Recurse){
        $DifferenceHashes = Get-ChildItem $DifferenceDirectory -File -Recurse| %{Get-FileHash -Algorithm $Algo -Path $_.FullName}
        $ReferenceHashes = Get-ChildItem $ReferenceDirectory -File -Recurse | %{Get-FileHash -Algorithm $Algo -Path $_.FullName}
    }else{
        $DifferenceHashes = Get-ChildItem $DifferenceDirectory -File | %{Get-FileHash -Algorithm $Algo -Path $_.FullName}
        $ReferenceHashes = Get-ChildItem $ReferenceDirectory -File | %{Get-FileHash -Algorithm $Algo -Path $_.FullName}
    }
 
    # Display the results of hashing to the Console and pipe to output file
    if($Path -ne ""){
        $DifferenceHashes + $ReferenceHashes | Format-Table -AutoSize | Tee-Object -FilePath $Path -Append
    }else{
        $DifferenceHashes + $ReferenceHashes | Format-Table -AutoSize
    }

    # If the -NoHelp parameter is supplied, do not print out helper information table
    if(-not $NoHelp){
        Write-Host "Compare File Hashes`n*******************************" -ForegroundColor Cyan

        # Output a helper information table
        [String[]]$DisplayTable = @(@("Role","Path","Indicator"),@("Reference",$ReferenceDirectory,"<="),@("Difference",$DifferenceDirectory,"=>"));
        $DisplayTable | Format-Table

        Write-Host "*******************************`n"
    }

    # Perform comparison
    if($Path -ne ""){
        Compare-Object -ReferenceObject $ReferenceHashes -DifferenceObject $DifferenceHashes -Property Hash | Select-Object Hash,Path,SideIndicator | Tee-Object -FilePath $Path -Append
    }else{
        Compare-Object -ReferenceObject $ReferenceHashes -DifferenceObject $DifferenceHashes -Property Hash -PassThru | Select-Object Hash,Path,SideIndicator 
    }
}