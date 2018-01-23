## This function is used to unpack child folders into parent folder.
function Start-FolderUnpack {
    param(
        # FilePath
        [Parameter(Mandatory = $true)]
        [String]
        $FilePath,
        # Delete child directories? default true
        [Parameter(Mandatory = $false)]
        [bool]
        $DeleteDir = $true
    )

    # Retrieves directories in the root path
    $ChildDir = Get-ChildItem $filepath -directory
    # gets all files under root directory and sub directories
    $NestedItems = Get-ChildItem $ChildDir.FullName -File -Recurse
        # Checks if file already exists in root directory and renames it.
        # uses a loop to check iterations of the (x) where x is the iterative integer
        foreach ($item in $NestedItems) {
            $result = test-path ("$filepath" + "\$item")
            $i = 1
            $itemname = $item.basename
            $itemext = $item.extension
            if ($result -eq $true) {
                Do {
                    if ($result -eq $false) {
                    }
                    $NewFileName = ("$filepath" + "\$itemname" + "($i)" + "$itemext")
                    $result = Test-Path $NewFileName
                    $i += 1
                }
                # moves file with newly created name
                while ($result -eq $true)
                move-Item -Path $item.fullname -Destination $NewFileName
            }
            else {
                # Moves file
                Move-Item $item.fullname -Destination $FilePath
            }
        }
    # Deletes the directories after moves have been completed.
    if ($DeleteDir -eq $true) {
        Remove-Item $ChildDir.fullname -Force -Confirm:$false -Recurse
    }
}