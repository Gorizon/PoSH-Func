function Remove-IFSuserMembership {
    ##############################
    #.SYNOPSIS
    #This cmdlet removes selected user from all groups other than Domain Users
    #
    #.DESCRIPTION
    #This cmdlet pulls a list of groups the user is a part of then goes through each group and 
    #removes the user from it.
    #At the end of the script, it runs a test to see whether or not groups were all successfully
    #removed.  By the end of the removal command the user should only be a part of the "domain users"
    #group.  The cmdlet checks to see if the users is a part of more than the domain users group 
    #and outputs feedback to the end user.
    #
    #.PARAMETER IFSUser
    #User to be removed from all membership
    #
    ##############################
    param(
        # IFSUser
        [Parameter(Mandatory = $true)]
        $IFSUser
    )
    $ErrorActBefore = $ErrorActionPreference
    $ErrorActionPreference = 'silentlycontinue'
    $CurrentAdGroups = Get-ADPrincipalGroupMembership -Identity $IFSUser
    ForEach ($Group in $CurrentAdGroups) {
        Remove-ADGroupMember -Identity $Group -Members $IFSUser -Confirm:$false
    }
    $ErrorActionPreference = $ErrorActBefore

    $VerifyGroups = Get-ADPrincipalGroupMembership -Identity $IFSUser
    $CountGroups = $VerifyGroups | Measure-Object
    $CountGroupsResult = $CountGroups.count -eq 1

    if (($VerifyGroups.name -eq "Domain Users") -and ($countgroupsresult -eq $true)) {
        Write-Host "$IFSUser Successfully Removed from all groups" -ForegroundColor Green
    }
    else {
        Write-host "There was an issue removing $IFSuser from one or more groups" -ForegroundColor Red
        Return
    }
}