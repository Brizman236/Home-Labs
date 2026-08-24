Write-Host "=========== SCRIPT FOR OUs CREATION ===========" -ForegroundColor Cyan
# Chemin parent
$ParentPath = "DC=nexgen,DC=lab"

# OUs to create
$ParentOU = [PSCustomObject]@{
    Name = "NexGen-Infrastructures"
    Path = $ParentPath
}

# Sub OUs
$OUs = New-Object System.Collections.Generic.List[String]
$OUs.Add('IT')
$OUs.Add('HR')
$OUs.Add('R&D')
$OUs.Add('Finance')
$OUs.Add('Sales')

# Creation of Parent OU
# Checking if it exist
Write-Host "=========== Creation of Parent OU NexGen-Infrastructures ===========" -ForegroundColor Cyan

$existence = try {
    $null = Get-ADOrganizationalUnit -Identity "OU=$($ParentOU.Name),$ParentPath" -ErrorAction Stop
    $true
} catch {
    $false
}

if ($existence) {
    #If it exist, let's just
    Write-Host "[-] Already existed" -ForegroundColor Green
} else {
    New-ADOrganizationalUnit -Name $ParentOU.Name -Path $ParentPath -ProtectedFromAccidentalDeletion $false
    Write-Host "[+] Created" -ForegroundColor Yellow
}

# Creation of the rest of OUs
Write-Host "=========== Creation of Child OUs ===========" -ForegroundColor Cyan
$SubOUPath = "OU=$($ParentOU.Name),$ParentPath"

# Checking if OU exist before or after moving

$OUs | ForEach-Object {

    $IfOuExist1 = try {
        $null = Get-ADOrganizationalUnit -Identity "OU=$($_),$SubOUPath" -ErrorAction Stop
        $true
    } catch {
        $false
    }

    $IfOuExist2 = try {
        $null = Get-ADOrganizationalUnit -Identity "OU=$($_),NexGen-Tier2,$SubOUPath" -ErrorAction Stop
        $true
    } catch {
        $false
    }
    
    if ($IfOuExist1 -or $IfOuExist2){
        Write-Host "[-] ( item : OU=$_,$SubOUPath ) Already existed" -ForegroundColor Green
    } else {
        New-ADOrganizationalUnit -Name $_ -Path $SubOUPath -ProtectedFromAccidentalDeletion $false
        Write-Host "[+] ( item : OU=$_ ) Created" -ForegroundColor Yellow
    }
}
