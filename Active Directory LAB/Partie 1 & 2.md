___
# Introduction

Ce projet consiste en la mise en place d'un domaine Active Directory avec un **Domain Controller**, une machine cliente **Windows** et une machine avec **Kali Linux** installé, 

Le LAB est divisé en 3 grandes parties :
- La **mise en place** et **configuration** du domaine AD
- Les **tests de pénétrations**
- L'**hardening** du domaine AD

Ce document se concentrera sur les 2 premières parties.

___

# Topologie initiale :

Voici la topologie que nous allons implémenter dans ce document :

![[WhatsApp Image 2025-12-04 at 16.16.28.jpeg]]


___

# Partie 1 : Mise en place et configuration de l'AD

Dans cette premiere partie nous allons :
- Installer le **DC** (Windows Server) et configurer le domaine **Active Directory**
- Installer et configurer la machine cliente

---

## Etape 1 : Installation du DC et configuration du domaine

On installera un Windows Server 2022 dans VMWare avec les configs suivantes :
- 2 vCPUs
- 4Go RAM
- 60Go de stockage
Nommons-le DC1 :

![[Pasted image 20251128134613.png]]

___
## Etape 2 : Installation de l'ADDS

Notre domaine AD sera `cyber.lab`

```powershell
Add-WindowsFeature Ad-Domain-Services
Install-ADDSForest -DomainName "cyber.lab"
```

![[Pasted image 20251128141938.png]]

___
## Etape 3 : Création de la structure des OU

Voici la structure à créer :
```
CYBER_LAB 
	├── ADMINS
	├── USERS
	└── COMPUTERS
```

```powershell
New-ADOrganizationalUnit -Name "CYBER_LAB" -Path "DC=cyber,DC=lab"
New-ADOrganizationalUnit -Name "USERS" -Path "OU=CYBER_LAB,DC=cyber,DC=lab"
New-ADOrganizationalUnit -Name "ADMINS" -Path "OU=CYBER_LAB,DC=cyber,DC=lab"
New-ADOrganizationalUnit -Name "COMPUTERS" -Path "OU=CYBER_LAB,DC=cyber,DC=lab"
```

✔ ADMINS → comptes administrateurs 
✔ USERS → comptes utilisateurs 
✔ COMPUTERS → machines du domaine

___

## Etape 4 : Création des comptes et ajout des machines

**Comptes**
- alice - pass:love@123 OU:USERS
- bob - pass:pass#12 OU:USERS
- admin1 (membre de "Admins du domaine") - pass:sunny#24 OU:ADMINS

**Machine WIN10-CLIENT**

Pour ajouter la machine cliente `WIN10-CLIENT` , il nous d'abord configurer son DNS. Regardons la configuration de la carte réseau du DC :

![[Pasted image 20251128211534.png]]

Nous allons maintenant l'utiliser comme serveur DNS sur `WIN10-CLIENT` :

![[Pasted image 20251128211702.png]]

Vérifions si le DNS marche avec `nslookup cyber.lab` :

![[Pasted image 20251128212012.png]]

Nous allons maintenant ajouter le compte de la machine au domaine :

```powershell
# Sur le DC
New-ADComputer -Name "WIN10-CLIENT" -Path "OU=COMPUTERS,OU=CYBER_LAB,DC=cyber,DC=lab"
```

Sur ma machine allons dans *Paramètres > Système > Paramètres avancéés du système > Nom de l'ordinateur > Modifier...* :

![[Pasted image 20251128220655.png]]

En cliquant sur OK on nous demande d'entrer les identifiants d'un compte autorisé à joindre le domaine, dans notre cas ici c'est `Administrateur`.

![[Pasted image 20251128220827 1.png]]

Vérifions l'intégration en nous connectant en tant que `alice` :

![[Pasted image 20251128222027.png]]

![[Pasted image 20251128222320.png]]

___

# Partie 2 : Tests de pénétrations

## 1. Enumération des deux hôtes

![[Pasted image 20251203194942.png]]
![[Pasted image 20251203195206.png]]

Domaine Active Directory trouvé : `cyber.lab`.

___
## 2. Enumération du domaine sans creds `cyber.lab`

#### NetExec avec une session nul et le compte 'Invité'

![[Pasted image 20251203200207.png]]

- Le compte `Invité` est désactivé par défaut
- L'énumération n'est pas possible avec la session nulle

#### Kerbrute : brute-force des utilisateurs

![[Pasted image 20251203194435.png]]

2 utilisateurs ont été trouvé. On peut tenter du ASREP-Roasting.

#### ASREP-Roasting avec les utilisateurs trouvés

![[Pasted image 20251203200649.png]]

La préauthentification est désactivé par défaut.

#### Kerbrute : brute-force du mot de passe d'un utilisateur 

![[Pasted image 20251203201823.png]]

Mot de passe d'alice trouvé : `love@123`.

___

## 3. Escalation de privileges

#### Password Spraying avec le mot de passe d'alice

![[Pasted image 20251203202211.png]]

L'Admnistrateur a le même mot de passe. Prenons l'accès au DC avec Evil-WinRM :

![[Pasted image 20251203202415.png]]

Compromission totale !

___


















