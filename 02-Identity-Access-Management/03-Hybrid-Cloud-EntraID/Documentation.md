## Context

Nex Gen run only with **On-premise** architecture. Services like storage with Nextcloud and development tools are locked behind the firewall. It is a choice of sovereignty.

**The reality** : Collaborators can not longer work efficiently when mobile. Accessing a simple HR file our a development ressource, they need to pass through a complex VPN tunel. This VPN become a bottleneck, and difficult to maintain by IT Team. Most criticaly, it exposes the internal network to potentially intrusions as soon as a external host is compromised.

We need a solution that assure to external collaborators accessing enterprise ressources securely (minimize internal network exposure) with assuring **identity and access management** (ovoid identity spawl). 

That's where **Cloud-based Identity and Access Management** comes into play. Instead of opening multiple vulnerable inbound VPN connections, we'll deleguate external authentication to a **Cloud Idendity Provider**.

**Outcomes** :
- Mobile Collaborator can access to internal applications and services **remotely** : Access will no longer depend on the network. Whever the employee is, he has access (he must be authenticated of course)
- Only one source of trust

___
### Step 1 : The Foundation

**Goal :** Allow NexGen, instead of creating new users, new identities on the **Cloud**, to extend its on-premise directory to the **Cloud**. Security remains centralized and administration simplified. 

> **NB** : In this Lab I use the Free version of **Entra ID**, **Microsoft Free Entra ID**

Before starting the configuration, we have to handle something, our **directory domain name**. 

On **Entra ID**, domain names must be **routable**, however ours is not. To solve this without buying a new domain name, we'll use an **Alternative User Principal Name (UPN)** like `user@microsoftdomainname.com` for all users.

#### Configuring alternative UPN suffix
My microsoft domain name is : `ericyawilhit37gmail.onmicrosoft.com`.
Firstly, we have to add an **alternative UPN suffix** for our domain :
- Open **Server Manager** and the tools **Active Directory Domains and Trusts**
- Rigth click on **Active Directory Domains and Trusts**
	![Pasted image 20260701001257.png](Pasted%20image%2020260701001257.png)
- Add the new Alternative UPN suffix `ericyawilhit37gmail.onmicrosoft.com`
	![Pasted image 20260701001421.png](Pasted%20image%2020260701001421.png)

And then change the UPN suffix for all users. I'll use a PowerShell Scripting to change UPN for all users :

```powershell
# 1. Configuration des variables
$OU = "OU=NexGen-Infrastructures,DC=nexgen,DC=lab"
$AncienSuffixe = "@nexgen.lab"
$NouveauSuffixe = "@ericyawilhit37gmail.onmicrosoft.com" 

# 2. Récupération des utilisateurs
$utilisateurs = Get-ADUser -Filter * -SearchBase $OU -Properties UserPrincipalName 

# 3. Boucle de modification
foreach ($user in $utilisateurs) {
# On vérifie si l'UPN finit bien par l'ancien suffixe pour éviter les erreurs
	if ($user.UserPrincipalName -like "*$AncienSuffixe") {
		# On construit le nouvel UPN
		$nouvelUPN = $user.UserPrincipalName.Replace($AncienSuffixe, $NouveauSuffixe)
		Write-Host "Modification de $($user.SamAccountName) : $($user.UserPrincipalName) -> $nouvelUPN"
		# Commande avec -WhatIf (À enlever pour appliquer réellement)
		Set-ADUser -Identity $user.DistinguishedName -UserPrincipalName $nouvelUPN
	
	}

}
```


The steps bellow will be done on our Windows Server aka the **Domain Controller** :
- On the home page of **Entra ID**, go down through the menu bar and click on **Entra Connect**
- We'll have two options : **Cloud Sync** and **Connect Sync**. The first is the quickest but it need a License. So we'll use the second, **Connect Sync** :
	![Pasted image 20260629230029.png](Pasted%20image%2020260629230029.png)
- After the download, click on the setup to launch the installation. This windows bellow will be open after the installation :
	![Pasted image 20260629233031.png](Pasted%20image%2020260629233031.png)
	






