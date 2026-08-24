$ParentPath = "DC=nexgen,DC=lab"
$Admins = New-Object 'System.Collections.Generic.List[System.Object]'
$Admins.AddRange(@(
    [PSCustomObject]@{
        Name = "adm-eyawil-t0"
        Group = "GG-T0-Admins"
        Path = "OU=NexGen-Tier0,$ParentPath"
    }
    
    [PSCustomObject]@{
        Name = "adm-eyawil-t1"
        Group = "GG-T1-Admins"
        Path = "OU=NexGen-Tier1,$ParentPath"
        Permission = @("NEXGEN\GG-T1-Admins:CCDC;computer;", "NEXGEN\GG-T1-Admins:CCDC;msDS-GroupManagedServiceAccount;", "NEXGEN\GG-T1-Admins:GA;;computer")
    }

    [PSCustomObject]@{
        Name = "adm-eyawil-t2"
        Group = "GG-T2-Admins"
        Path = "OU=NexGen-Tier2,$ParentPath"
        Permission = @("NEXGEN\GG-T2-Admins:CA;Reset Password;user", "NEXGEN\GG-T2-Admins:RPWP;lockoutTime;user", "NEXGEN\GG-T2-Admins:GA;;user")
        
    }
))

$Password = ConvertTo-SecureString "Pass@word123!" -AsPlainText -Force

foreach ($adm in $Admins) {
    $IfGroupExist = Get-ADGroup -Filter "Name -eq '$($adm.Group)'" 
    $IfUserExist = Get-ADUser -Filter "Name -eq '$($adm.Name)'"

    if (!$IfGroupExist){
        New-ADGroup -Name $adm.Group -Path "OU=Admin-Groups,$($adm.Path)" -GroupCategory Security -GroupScope Global
        Write-Host "[+] ( item : $($adm.Group) ) Created" -ForegroundColor Yellow
    }

    if (!$IfUserExist) {
        New-ADUser -Name $adm.Name `
        -SamAccountName $adm.Name `
        -Path "OU=Admin-Accounts,$($adm.Path)" `
        -AccountPassword $Password `
        -ChangePasswordAtLogon $true `
        -Enabled $true

        Add-ADGroupMember -Identity $adm.Group -Members $adm.Name

        Write-Host "[+] ( item : $($adm.Name) ) Created" -ForegroundColor Yellow
    }
    
    $IfUserInGroup = Get-ADGroupMember -Identity $adm.Group | Where-Object { $_.SamAccountName -eq "$($adm.Name)" }
    if (!$IfUserInGroup) {
        Add-ADGroupMember -Identity $adm.Group -Members $adm.Name
    } else {
        Write-Host "[-] ( item : $($adm.Name) ) already existed and added to $($adm.Group)" -ForegroundColor Green
    }

    # Delegation of Permissions
    if($adm.Group -eq "GG-T0-Admins"){
        $IfGroupInDmAdm = Get-ADGroupMember -Identity "Domain Admins" | Where-Object { $_.name -eq "$($adm.Group)" }
        
        if ($IfGroupInDmAdm) {
            Write-Host "[-] ( item : $($adm.Group) ) already added to Domain Admins Group" -ForegroundColor Green
        } else {
            Add-ADGroupMember -Identity "Domain Admins" -Members $adm.Group
            Write-Host "[+] ( item : $($adm.Group) ) added to Domain Admins" -ForegroundColor Yellow
        }
    } else {
        foreach($perm in $adm.Permission){
            dsacls.exe $adm.Path /G $perm /I:S | Out-Null
        }   
        Write-Host "[+] Permissions delegated to $($adm.Name)" -ForegroundColor Yellow

    }
}