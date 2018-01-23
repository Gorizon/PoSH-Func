function Find-Duplicates {
    param(
        # Root folder to search all items
        [Parameter(Mandatory = $true)]
        [string]
        $filepath
    )

    # Initializing, creating base Hash Table and gathering all files.
    $allfiles = Get-ChildItem -Path $filepath -file -Recurse
    $FileIndex = @{}

    # Checking files 1 by 1
    # Speed this up with multi threading?  for large quantities of files this is going to take a long time...
    foreach ($file in $allfiles) {
        # Setting up PSobject for storage of individual item properties for comparison and adding to hash table
        $FileProperties = New-Object psobject

        # Retrieving file properties here
        $FileHash = Get-FileHash $file.fullname
        $FileProperties = @{
            FullFilePath = @($file.fullname)
            FileHash     = @($FileHash.hash)
            FileSize     = $file.Length
        }

        # Testing whether or not this is copy already? searches file name for (x) as is standard for windows duplicates
        if ($file.name -match "\(\d{1,2}\)") {
            # strips the (x) from the file name
            $OriginalFileName = ($file.Name -replace "( *|)\(\d{1,2}\)( *|)", "")
            # Tests the file name that has had the (x) stripped to see if a key value has already been set and if the file size is the same
            if (($FileIndex.ContainsKey($OriginalFileName)) -and ($FileProperties.FileSize -eq $FileIndex.$OriginalFileName.FileSize)) {
                # If the file is detected, it adds the full file path of the item to Hash Table value
                $FileIndex.$OriginalFileName.FullFilePath += $FileProperties.FullFilePath
                # Checks if the file hash exists inside the Hash Table if not adds it to the FileHash Array
                if ($FileIndex.$OriginalFileName.FileHash -ne $FileProperties.FileHash) {
                    $FileIndex.$OriginalFileName.FileHash += $FileProperties.FileHash
                }
            }
            # If the file test does not succeed, it adds the HashTable key and entry
            else {
                $FileIndex.Add($OriginalFileName, $FileProperties)
            }
        }
        # If the file name does not contain (X) it Tests the filename to existing keys and the file size
        elseif (($fileIndex.ContainsKey($file.Name) -and ($FileProperties.FileSize -eq $FileIndex.($file.name).FileSize))) {
            # adds the Value to the hash table
            $FileIndex.($file.name).FullFilePath += $FileProperties.FullFilePath
            if ($FileIndex.($file.name).FileHash -ne $FileProperties.FileHash) {
                $FileIndex.($file.name).FileHash += $FileProperties.FileHash
            }
        }
        else {
            # Adds the value to the hash table.
            $FileIndex.Add($file.Name, $FileProperties)
        }
    }
    $FileIndex
}