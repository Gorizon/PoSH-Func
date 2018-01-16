Function Remove-O365License {
    ##############################
    #.SYNOPSIS
    #Short description
    #
    #.DESCRIPTION
    #Long description
    #
    #.PARAMETER UserPrincipalName
    #Parameter description
    #
    #.EXAMPLE
    #An example
    #
    #.NOTES
    #General notes
    ##############################
    param(
        # User Principal Name (User@YourDomain.com)
        [Parameter(Mandatory = $true)]
        [string]
        $UserPrincipalName
    )
    $MSOLuser = get-msoluser -UserPrincipalName $UserPrincipalName
    if ($MSOLuser.islicensed -eq $true) {
        Set-MsolUserLicense -UserPrincipalName $UserPrincipalName -RemoveLicenses $MSOLuser.licenses.accountskuid
    }
}
