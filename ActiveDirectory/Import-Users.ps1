function Import-Users {
    param (
        [Parameter(Mandatory=$true, ParameterSetName="Text")]
        [Alias("Text")]
        [ValidateScript({[System.IO.Path]::GetExtension($_) -eq ".txt"})]
        [String]
        $TXT,
        [ValidateRange(1,[Int32]::MaxValue)]
        [Parameter(ParameterSetName="Text")]
        [Parameter(ParameterSetName="Excel")]
        [Int32]
        $HeaderRows,
        [Parameter(ParameterSetName="CSV")]
        [ValidateRange(1,[Int32]::MaxValue)]
        [Int32]
        $Header,
        [Parameter(ParameterSetName="Excel")]
        [Parameter(ParameterSetName="CSV")]
        [ValidateRange(1,[Int32]::MaxValue)]
        [Int32]
        $Column,
        [Parameter(Mandatory=$true, ParameterSetName="CSV")]
        [ValidateScript({[System.IO.Path]::GetExtension($_) -eq ".csv"})]
        [String]
        $CSV,
        [Parameter(Mandatory=$true, ParameterSetName="Excel")]
        [Alias("Excel","XLSX")]
        [ValidateScript({[System.IO.Path]::GetExtension($_) -eq ".xlsx" -or [System.IO.Path]::GetExtension($_) -eq ".xls"})]
        [String]
        $XLS,
        [Parameter(ParameterSetName="Excel",Mandatory=$false)]
        [String]
        $WorkbookName
    )
    #Requires -Modules ImportExcel
    #Requires -Version 5.1
    Import-Module ImportExcel

    [String[]]$Usernames;

    # Begin processing the text file
    if ($TXT -ne "") {
        # Test path
        if (Test-Path $TXT) {
            # Import content from the text file
            $Usernames = [System.IO.File]::ReadAllLines($TXT);
            
            # remove headings
            if ($HeaderRows -gt 0) {
                for ($t = 0; $t -le $HeaderRows; $t++) {
                    $Usernames[$t] = "";
                }
            }
           
        }else{
            Write-Error "Unable to resolve path for text file input."
        }
    }
    
    # Begin processing CSV file
    if($CSV -ne ""){
        # Test path
        if (Test-Path $CSV) {
            # Import content from the CSV file
            
            # parse the header row as a header, not part of the csv file
            ## get the first 5 lines of the csv file, then read the header names from row specified in parameter
            if($Header -gt 0){
                try{
                    [String[]]$head = (Get-Content -Path $CSV -TotalCount 5)[$Header] -split ","
                }catch{
                    Write-Error "Unable to parse headers in the provided CSV file" -ErrorAction Stop -Category ParserError
                }

                # get the column by specified number after reading the headings
                $Usernames = (Import-Csv -Path $CSV -Header $head) | Select-Object $head[$Column]
            }
        }else{
            Write-Error "Unable to resolve path for CSV file input."
        }
    }

    # Begin processing the Excel file
    if ($XLS -ne "") {
        # Test path
        if (Test-Path $XLS) {
            # Set the name of the worksheet if different from the standard default "Sheet1"
            [String]$worksheet
            if ($WorkbookName -ne "") {
                $worksheet = $WorkbookName
            }else{
                $worksheet = "Sheet1"
            }

            # Import the data using Import-Excel module
            $Usernames = @(Import-Excel -Path $XLS -WorksheetName $worksheet -NoHeader -StartColumn $Column -EndColumn $Column -DataOnly)

            ## TODO: finish parsing data from the imported XLS file
            
        }else{
            Write-Error "Unable to resolve path for XLS file input."
        }
    }

    # return $Usernames

    
}
Import-Users -XLS "Y:\pboyer2\Users in a specific domain.xlsx" -Column 5 -HeaderRows 5