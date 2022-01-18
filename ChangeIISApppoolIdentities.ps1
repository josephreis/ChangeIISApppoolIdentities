#Enter the list of servernames

$serverList = @"
#Servername1
#Servername2
#Servername3
"@ -split "`r`n" | ForEach-Object Trim


Invoke-Command $serverList {

    Import-Module WebAdministration

    $appPoolList = "
    AppPool,Identity
    APPPOOLNAME1,IdentityNAME1$
    APPPOOLNAME2,IdentityNAME2$
    APPPOOLNAME3,IdentityNAME3$
    " -split "`r`n" | ForEach-Object Trim | Where-Object Length | ConvertFrom-Csv

    #Use the match in the next part to search for what servers in what domain you want. 

    $domain = if ($env:COMPUTERNAME -match "\ARCHP") { "PROD" } else { "NONPROD" }

    $appPoolList |
        ForEach-Object {
            Write-Host "Setting $($_.AppPool) identity to $($_.Identity)" -ForegroundColor Cyan
            #Line of code below is Removing $ and then adding it just incase someone changes the identitys without the $ and some with the $
            Set-ItemProperty "IIS:\AppPools\$($_.AppPool)" processModel @{identitytype=3;username="$domain\$($_.Identity.TrimEnd('$'))$";password=''}
            Restart-WebAppPool $_.AppPool
        }

}