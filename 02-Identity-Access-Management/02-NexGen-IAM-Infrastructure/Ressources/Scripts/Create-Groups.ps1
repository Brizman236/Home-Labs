Write-Host "=========== SCRIPT FOR GROUPS CREATION ===========" -ForegroundColor Cyan
# Define a list for groups
$Groups = New-Object 'System.Collections.Generic.List[System.Object]'

$Groups.AddRange(@(
    [PSCustomObject]@{
        Name = "gg-NexGen-Staff"
        OU = "OU=NexGen-Infrastructures,DC=nexgen,DC=lab"
    }
    [PSCustomObject]@{
        Name = "gg-IT-Users"
        OU = "OU=IT,OU=NexGen-Infrastructures,DC=nexgen,DC=lab"
    }
    [PSCustomObject]@{
        Name = "gg-HR-Users"
        OU = "OU=HR,OU=NexGen-Infrastructures,DC=nexgen,DC=lab"
    }
    [PSCustomObject]@{
        Name = "gg-R&D-Users"
        OU = "OU=R&D,OU=NexGen-Infrastructures,DC=nexgen,DC=lab"
    }
    [PSCustomObject]@{
        Name = "gg-Finance-Users"
        OU = "OU=Finance,OU=NexGen-Infrastructures,DC=nexgen,DC=lab"
    }
    [PSCustomObject]@{
        Name = "gg-Sales-Users"
        OU = "OU=Sales,OU=NexGen-Infrastructures,DC=nexgen,DC=lab"
    }
)
)

$Groups | ForEach-Object {

    $IfGroupExist = try {
        $null = Get-ADGroup -Identity "CN=$($_.Name),$($_.OU)" -ErrorAction Stop
        $true
    }
    catch {
        $false
    }

    if ($IfGroupExist) {
        Write-Host "[-] ( item : $($_.Name) ) already existed" -ForegroundColor Green
    } else {
        New-ADGroup -Name $_.Name -GroupCategory Security -GroupScope Global -Path $_.OU
        Write-Host "[+] ( item : $($_.Name) ) Created" -ForegroundColor Yellow
        
        if ( $_.Name -ne "gg-NexGen-Staff") {
            Add-ADGroupMember -Identity "gg-NexGen-Staff" -Members $($_.Name)
            Write-Host "$($_.Name) [->] Added to gg-NexGen-Staff" -ForegroundColor Blue
        }
    }

}
