# This phase consist of creating the OU Structure according to the Tiering Model

Write-Host "TASK 1 : Creating the OU Structure" -ForegroundColor Cyan

$OuStructure = New-Object 'System.Collections.Generic.List[System.Object]'
$ParentPath = "DC=nexgen,DC=lab"

$OuStructure.AddRange(@(
    [PSCustomObject]@{
        Name = "NexGen-Tier0"
        SubOU = @("Admin-Accounts", "Admin-Groups", "Service-Accounts", "Computers")
    }
    
    [PSCustomObject]@{
        Name = "NexGen-Tier1"
        SubOU = @("Admin-Accounts", "Admin-Groups", "Service-Accounts", "Computers")
    }

    [PSCustomObject]@{
        Name = "NexGen-Tier2"
        SubOU = @("Admin-Accounts", "Admin-Groups", "Standard-Users", "Computers")
    }

))

$OuStructure | ForEach-Object {

    $FullTierPath = "OU=$($_.Name),$ParentPath"
    $ifTierExist = try {
        $null = Get-ADOrganizationalUnit -Identity $FullTierPath -ErrorAction Stop
        $true
    }
    catch {
        $false
    }

    if($ifTierExist){
        Write-Host "[-] ( item : $($_.Name) ) already existed" -ForegroundColor Green
    } else {
        New-ADOrganizationalUnit -Name $_.Name -Path $ParentPath
        Write-Host "[+] ( item : $FullTierPath ) Created" -ForegroundColor Yellow
    }

    foreach ($subOU in $_.SubOU){
        
        $SubOUPath = "OU=$subOU,$FullTierPath"
        $IfSubOuExist = try {
            $null = Get-ADOrganizationalUnit -Identity $SubOUPath -ErrorAction Stop
            $true
        }
        catch {
            $false
        }

        if($IfSubOuExist){
            Write-Host "[-] ( item : $SubOUPath ) already existed" -ForegroundColor Green
        } else {
            New-ADOrganizationalUnit -Name $subOU -Path $FullTierPath 
            Write-Host "[+] ( item : $SubOUPath ) Created" -ForegroundColor Yellow
        }
    }
}

# 2. Moving svc-nexgen-webapp account under Service-Accounts in NexGen-Tier 1
Write-Host "TASK 2 : Moving svc-nexgen-webapp account under Service-Accounts in NexGen-Tier 1" -ForegroundColor Cyan
$IfMoved = try {
    $null = Get-ADUser -Identity "CN=svc-nexgen-webapp,OU=IT,OU=NexGen-Infrastructures,$ParentPath" -ErrorAction Stop
    $false
}
catch {
    $true
}

if($IfMoved){
    Write-Host "[-] ( item : svc-nexgen-webapp ) already moved" -ForegroundColor Green
} else {
    Move-ADObject -Identity "CN=svc-nexgen-webapp,OU=IT,OU=NexGen-Infrastructures,$ParentPath" -TargetPath "OU=Service-Accounts,OU=NexGen-Tier1,$ParentPath"
    Write-Host "[-] ( item : svc-nexgen-webapp ) moved" -ForegroundColor Yellow
}

# 3. Create the User/Group structure in each department OU under NexGen-Infrastructures OU and move objects in their right place
Write-Host "TASK 3 : Create the User/Group structure in each department OU under NexGen-Infrastructures OU and move objects in their right place" -ForegroundColor Cyan

$IfNotMoved = try {
    $null = Get-ADOrganizationalUnit -Identity "OU=NexGen-Infrastructures,$ParentPath" -ErrorAction Stop
    $true
}
catch {
    $false
}

if ($IfNotMoved) {
    $DepartmentOU = Get-ADOrganizationalUnit -SearchBase "OU=NexGen-Infrastructures,$ParentPath" -SearchScope OneLevel -Filter *
    
    $SubOU = @("Users", "Groups")
    
    foreach ($ou in $DepartmentOU) {
        foreach ($sub in $SubOU){
            $FullSubOUPath = "OU=$sub,$($ou.DistinguishedName)"
            $IfSubOuExist = try {
                $null = Get-ADOrganizationalUnit -Identity $FullSubOUPath
                $true
            }
            catch {
                $false
            }
    
            if($IfSubOuExist){
                Write-Host "[-] ( item : $FullSubOUPath ) already existed" -ForegroundColor Green
            } else {
                New-ADOrganizationalUnit -Name $sub -Path $ou.DistinguishedName
                Write-Host "[+] ( item : $FullSubOUPath ) Created" -ForegroundColor Yellow
            }
    
            # Let's move object to their right place
            $objectClass = $sub.ToLower().Substring(0, $sub.Length - 1)
            $objects = Get-ADObject -SearchBase $ou.DistinguishedName -Filter "ObjectClass -eq '$($objectClass)'"
            foreach ($object in $objects){
                Move-ADObject -Identity $object.DistinguishedName -TargetPath $FullSubOUPath
            }
    
        }
    }
    
    # 3. Move NexGen-Infrastructures under Standard-Users
    Write-Host "TASK 4 : Move NexGen-Infrastructures under Standard-Users" -ForegroundColor Cyan
    $IfMoved = try {
        $null = Get-ADOrganizationalUnit -Identity "OU=NexGen-Infrastructures,$ParentPath" -ErrorAction Stop
        $false
    }
    catch {
        $true
    }
    
        Move-ADObject -Identity "OU=NexGen-Infrastructures,$ParentPath" -TargetPath "OU=Standard-Users,OU=NexGen-Tier2,DC=nexgen,DC=lab
    "
        Write-Host "[+] ( item : OU=NexGen-Infrastructures,$ParentPath ) Moved" -ForegroundColor Yellow   
} else {
    Write-Host "[-] ( item : "OU=NexGen-Infrastructures,$ParentPath" ) already moved" -ForegroundColor Green
}

# 4. Moving Computers to their right place
Write-Host "TASK 5 : Move Computers" -ForegroundColor Cyan
$Computers = New-Object 'System.Collections.Generic.List[System.Object]'
$Computers.AddRange(@(
    [PSCustomObject]@{
        Name = "NXG-ADM-IT01"
        TargetPath = "OU=Computers,OU=NexGen-Tier2,$ParentPath"
    }
    
    [PSCustomObject]@{
        Name = "NXG-WKS-FIN01"
        TargetPath = "OU=Computers,OU=NexGen-Tier2,$ParentPath"
    }

    [PSCustomObject]@{
        Name = "NXG-SRV-APP01"
        TargetPath = "OU=Computers,OU=NexGen-Tier1,$ParentPath"
    }

))

$Computers | ForEach-Object {
    
    $IfMoved = try {
        $null = Get-ADComputer -Identity "CN=$($_.Name),$($_.TargetPath)"
        $true
    }
    catch {
        $false
    }

    if($IfMoved){
        Write-Host "[-] ( item : $($_.Name) ) already moved" -ForegroundColor Green
    } else {
        Move-ADObject -Identity "CN=$($_.Name),CN=Computers,$ParentPath" -TargetPath $_.TargetPath
        Write-Host "[+] ( item : $($_.Name) ) Moved" -ForegroundColor Yellow
        
    }
}