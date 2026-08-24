Write-Host "=========== SCRIPT FOR USERS IMPORT ==========="

# Fonction pour la génération du SAM Account Name : 1ere lettre du prénom + le nom
function Get-SamAccountName {
    param (
        [string]$FirstName,
        [string]$LastName
    )

    $FirstLetterFirstName = $FirstName.Substring(0, 1).ToLower()
    $NameToLower = $LastName.ToLower()
    
    $Sam = $FirstLetterFirstName + $NameToLower
    
    return $Sam
}
# General Path
$GlobalPath = "OU=NexGen-Infrastructures,DC=nexgen,DC=lab"

# Load CSV file
$UserList = Import-Csv -Path "C:\Users\Administrator\Documents\Users.csv"

foreach ($User in $UserList) {

    # Get the Sam Account Nam
    $Sam = Get-SamAccountName -FirstName $User.Firstname -LastName $User.Lastname

    try {
        # Verify if the User Exist
        $User = Get-ADUser -Identity $Sam -ErrorAction Stop
        
        # If the line upper run, the code bellow will be excuted
        Write-Host "[-] ( item : $Sam ) already existed" -ForegroundColor Green
        #Remove-ADUser -Identity $Sam -Confirm 
    } 
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        # Define a secure the password
        $Password = ConvertTo-SecureString "Pass@word123!" -AsPlainText -Force

        # Create the User in AD
        New-ADUser -Name "$($User.Firstname) $($User.Lastname)" `
        -SamAccountName $Sam `
        -Path "OU=$($User.Department),$GlobalPath" `
        -AccountPassword $Password `
        -ChangePasswordAtLogon $true `
        -UserPrincipalName "$Sam@nexgen.lab" `
        -Enabled $true `
        -Title $($User.Title)
        

        # Add this user to is OU Group
        Add-ADGroupMember -Identity "gg-$($User.Department)-Users" -Members $Sam

        Write-Host "[+] User $Sam created and added to gg-$($User.Department)-Users" -ForegroundColor Yellow
    }

}






