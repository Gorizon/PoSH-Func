function Remove-UserSessions {
    # Required Parameter for user to be removed
    Param(
        [Parameter(Mandatory = $true)]
        [string]$User
    )

    ## Retrieve's user OU from distinguished name
    $userDN = Get-Aduser -identity $User | Select-Object Distinguishedname
    $DNarray = $userDN -split ",", 3

    ## Parsing Distinguished name output into usable format
    $UserOU = ($DNarray[2]).trimend("}")

    ## Searching the Parent OU for listed computers in Active Directory
    $computer = get-adcomputer -filter * -SearchBase "$userou" | Where-Object enabled -EQ "true"

    ## Testing Connections to Computers
    workflow Connect-WsmanAll {
        Param ($computer)
        foreach -parallel ($comp in $computer.name) {
            $comp | Where-Object {Connect-WSMan $_}
        }
    } 

    Connect-WsmanAll -computer $computer -ErrorAction SilentlyContinue

    ## Retrieving list of available computers and Parsing data
    $locationbefore = get-location 
    Set-Location WSMan:
    $WSmanList = Get-ChildItem | Where-Object -property name -ne localhost
    $online = $WSmanList.Name
    foreach ($WSmanComp in $online) {
        Disconnect-WSMan -ComputerName $WSmanComp 
    }
    set-location $locationbefore

    ## Removing user from supplied list in parallel
    workflow Exit-ActiveUserSession {
        param ($online, $User)
        foreach -parallel ($OnlineComp in $online) {
            InlineScript {
                $Onlinecomp = $Using:OnlineComp
                $User = $Using:user
                Invoke-Command -ComputerName $Onlinecomp -ScriptBlock {
                    ## Retreives User Sessions from computer and Parses Data
                    ## Unfortunately Does not accurately Parse Data as Disconnected Sessions do not populate correct fields
                    $Sessions = (quser) -replace '\s{2,}', ',' | ConvertFrom-Csv
                    foreach ($userID in $Sessions) {
                        If ($userID.userName -like $Args[0]) {
                            ## Checks Data for Session ID by checking for integer value
                            $ErrorActionBefore = $ErrorActionPreference
                            $ErrorActionPreference = 'silentlycontinue'
                            $UserIDInt = [int]$userID.id
                            $userSessionInt = [int]$userID.SessionName
                            $ErrorActionPreference = $ErrorActionBefore
                            $useridint
                            $usersessionint
                            if ($UserIDInt -is [int]) {
                                Logoff $UserIDInt
                            }
                            else {
                                Logoff $userSessionInt
                            }
                        }
                    }
                } -ArgumentList $User, $Onlinecomp
            } 
        }
    }

    Exit-ActiveUserSession -online $online -User $User 
    $online = $null
}