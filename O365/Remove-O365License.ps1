Function Remove-O365License {
    ##############################
    #.SYNOPSIS
    #Removes License to O365 user
    #
    #.DESCRIPTION
    #This Cmdlet will remove licenses for O365 user
    #
    #TODO:
    #Add a way to pull licenses and display dialogue to user
    #Add Piping acceptance as well as array acceptance to parameters to skip over dialogue
    #Setup Logic to differentiate All from selected licenses
    #Setup Error handling
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
