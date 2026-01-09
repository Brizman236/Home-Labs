___

# Introduction

Dans un contexte où les systèmes informatiques sont de plus en plus exposés aux cyberattaques, la sécurisation des infrastructures numériques est devenue un enjeu majeur. 

Les attaques visant les entreprises se font toujours à travers le réseau car il lit l’ensemble des systèmes de l’organisation. De ce fait, sécuriser un réseau d’entreprise se trouve être une compétence essentielle pour tout individu aspirant à exercer dans la cybersécurité.

Le but de ce LAB est d’apprendre à : 
- **Installer et configurer un pare-feu** 
- **Comprendre le WAN et le LAN** 
- **Comprendre le NAT** 
- **Comprendre le principe des règles de pare-feu** 
- **Lire des logs**
- **Comprendre le fonctionnement d'un IDS**

Le LAB sera divisé en 3 phases : 
- La prise en main d'OPNsense
- Les tests réseaux et réactions défensives 
- La configuration de Suricata

___

## Environnement 

**Logiciel : VMware Workstation**

## Réseaux virtuelles à créer

| **VMnet** | **Type**  | Rôle           |
| --------- | --------- | -------------- |
| VMnet8    | NAT       | WAN (Internet) |
| VMnet2    | Host-Only | LAN (Interne)  |

## Machines virtuelles

| **VM**           | **Intecfaces** | Réseaux                     |
| ---------------- | -------------- | --------------------------- |
| OPNsense         | 2 NIC          | WAN (VMnet8) + LAN (VMnet2) |
| Client Ubuntu    | 1 NIC          | LAN (VMnet2)                |
| Kali (Attaquant) | 1 NIC          | LAN (VMnet2)                |

___

# Phase 1 : Prise en main d'OPNsense

OPNsense est une solution **open-source** de pare-feu basée sur **FreeBSD** utilisée pour sécuriser, segmenter et surveiller des réseaux informatiques. Elle offre des fonctionnalités très intéressantes telles que le **filtrage de paquets**, la **gestion des règles de pare-feu**, un **IDS/IPS** intégré (Suricata) et plus encore. 
Dans cette première phase nous allons installer OPNsense, et apprendre la configuration des règles de pare-feu.

___
### Etape 1 : Installation d'OPNsense
Tout d’abord il nous faudra télécharger l’image .iso d’OPNsense sur le site officiel https://opnsense.org/download/

![Pasted image 20251219224445](../Images/Pasted%20image%2020251219224445.png)

Puis créer une machine virtuelle avec ces spécifications : 
- 2 vCPUs
- 2048 Mo RAM
- 20 Go Stockage 
Ensuite ajoutons lui un Adaptateur configuré sur le VMnet2 

![Pasted image 20251219224705](../Images/Pasted%20image%2020251219224705.png)

Démarrons la VM et suivons ces étapes : 
- Saisir les identifiants `installer:opnsense` quand le prompt de login s’affiche 
- Suivre les paramètres d’installation par défaut
- A la fin de l’installation, se connecter avec les identifiants `root:opnsense`

![Pasted image 20251220163206](../Images/Pasted%20image%2020251220163206.png)
On a une adresse WAN avec un accès à internet. Pour vérifier, sélectionnont l'option 7 et tapant comme hôte à pinger `google.com` 

![Pasted image 20251220163501](../Images/Pasted%20image%2020251220163501.png)

Sur le LAN le DHCP est activé par défaut. Démarrons notre client Ubuntu, **dont l’adaptateur est configuré sur VMnet2**, et accédons à l’interface web d’OPNsense en tapant dans le navigateur https://192.168.1.1 : 

![Pasted image 20251220164843](../Images/Pasted%20image%2020251220164843.png)

Un assistant d'installation va se lancer, nous allons juste accepter les configurations par défaut. Après la finalisation de la configuration, nous aurons le dashboard d'OPNsense :

![Pasted image 20251220165107](../Images/Pasted%20image%2020251220165107.png)

___

### Etape 2 : Les règles de pare-feu

Ce sont des **instructions** configurées sur un pare-feu servant à **autoriser** ou **bloquer** un trafic en fonction des critères comme les **adresses IP**, le **protocole** ou encore le **port**. 
Sur OPNsense les règles de pare-feu peuvent être configurées dans *Firewall > Rules* + l'interface où l'on veut appliquer des règles.

![Pasted image 20251220165754](../Images/Pasted%20image%2020251220165754.png)

Sélectionnons l'interface **LAN** :

![Pasted image 20251220170024](../Images/Pasted%20image%2020251220170024.png)

Sur OPNsense, deux règles sont configurées par défaut :
- Le **ALLOW ANY ANY IPv4** qui autorise tout le trafic IPv4 dans le **LAN** 
- Le **ALLOW ANY ANY IPv6** qui autorise tout le trafic IPv6 dans le **LAN**

**Comment ces règles sont elles appliquée ?**
Les règles sur OPNsense suivent le principe du **First Match Wins** :
- Le firewall lit les règles de **haut en bas**
- La première règle qui **correspond au trafic** est appliquée
- Les règles suivantes ne seront jamais évaluées

Expérimentons cela avec un exemple avec deux cas de configuration.
**1er cas*

| **Ordre** | Action | Source | Destination | Service |
| --------- | ------ | ------ | ----------- | ------- |
| 1         | ALLOW  | ANY    | ANY         | IPv4    |
| 2         | ALLOW  | ANY    | ANY         | IPv6    |
| 3         | BLOCK  | ANY    | ANY         | ICMP    |

![Pasted image 20251220170931](../Images/Pasted%20image%2020251220170931.png)

![Pasted image 20251220171021](../Images/Pasted%20image%2020251220171021.png)

![Pasted image 20251220171216](../Images/Pasted%20image%2020251220171216.png)

Par défaut la règle se met tout en bas.
![Pasted image 20251220171732](../Images/Pasted%20image%2020251220171732.png)

**Résultat**
- Le ping passe
		![Pasted image 20251220171902](../Images/Pasted%20image%2020251220171902.png)
- **Pourquoi ?**
	- La première règle (ALLOW ANY) correspond déjà au trafic et a été appliquée
	- La 3e n'est jamais lue

**2e cas : Correction**
Ramenons la règle **BLOCK ICMP** à la première position

| **Ordre** | Action | Source | Destination | Service |
| --------- | ------ | ------ | ----------- | ------- |
| 3         | BLOCK  | ANY    | ANY         | ICMP    |
| 2         | ALLOW  | ANY    | ANY         | IPv4    |
| 3         | ALLOW  | ANY    | ANY         | IPv6    |

![Pasted image 20251220172507](../Images/Pasted%20image%2020251220172507.png)
![Pasted image 20251220172536](../Images/Pasted%20image%2020251220172536.png)

**Résultat**
- Le ping est bloqué
		![Pasted image 20251220172657](../Images/Pasted%20image%2020251220172657.png)
		![Pasted image 20251220172905](../Images/Pasted%20image%2020251220172905.png)
-  **Pourquoi ?** 
	- Le trafic correspond à la première règle
	- La 2e n'est jamais lue

Avec ces deux cas, on comprend assez bien le principe du **First Match Wins**

___

# Phase 2 : Attaque & Défense

Dans cette phase nous allons :
- Simuler une attaque réseau
- Lire et interpréter les logs firewall
- Bloquer l'attaquant

Il ne faudra installer Kali Linux dans une machine virtuelle puis le connecter au VMnet2, il aura une adresse IP automatique grâce au DHCP activé par défaut sur OPNsesne :

![Pasted image 20251220213652](../Images/Pasted%20image%2020251220213652.png)

Avant de commencer l'attaque, nous devons nous assurer que les paquets du LAN sont loggés par le pare-feu. Pour cela nous devons cocher *Log packets handled by this rule* dans la configuration des règles du LAN :

![Pasted image 20251223151639](../Images/Pasted%20image%2020251223151639.png)

![Pasted image 20251223151744](../Images/Pasted%20image%2020251223151744.png)

**Pourquoi cela ?**
Le pare-feu n'enregistre les paquets que si ces derniers **le traversent** et correspondent une **règle où l'on a activé le logging** 
___

## Etape 1 : Attaques Simples (Découverte)

Le but ici est de trouver les machines actives dans le réseau et d'identifier les ports ouverts.
Nous allons faire un scan nmap :

```sh
nmap 192.168.1.0/24 -Pn
```

> L'option `-Pn`  nous permet de désactiver le ping lors du scan nmap car nous avions précédemment créer une règle bloquant les trafics **ICMP**

![Pasted image 20251220214818](../Images/Pasted%20image%2020251220214818.png)

Nous avions identifié 3 machines actives :
- `192.168.1.1` qui est le pare-feu OPNsense qui a les ports DNS, HTTP et HTTPS ouverts
- `192.168.1.100` qui est l'adresse du client Ubuntu qui n'a pas de ports ouverts
- `192.168.1.101` qui est l'adresse de l'attaquant lui même

Tentons d'accéder à l'interface web de l'application web ;

![Pasted image 20251220220325](../Images/Pasted%20image%2020251220220325.png)

Ça a marché.

## Etape 2 : Lecture des logs côté OPNsense

> NB : J'ai lu les logs en même temps que les scans afin de mieux prendre les captures d'écran.

Avant
Pour lire les logs en live, nous allons entrer dans *Firewall > Log Files > Live View* :

![Pasted image 20251223145904](../Images/Pasted%20image%2020251223145904.png)

![Pasted image 20251223150133](../Images/Pasted%20image%2020251223150133.png)

Pour mieux inspecter les logs générés par les scans, nous allons filtrer selon l'adresse IP source de notre Kali Linux qui est  `192.168.1.101` :
![Pasted image 20251223150420](../Images/Pasted%20image%2020251223150420.png)

**Scan de découverte**

Durant le scan de découverte réseau `nmap 192.168.1.0/24 -Pn`, nous n'observons que des logs de paquets entre Kali et le pare-feu `192.168.1.1` :

![Pasted image 20251223152632](../Images/Pasted%20image%2020251223152632.png)

**Pourquoi n'y en a-t-il  pas pour Kali et la machine cliente ?** 
Le client Ubuntu et le Kali sont sur le même LAN, de ce fait le trafic est du LAN -> LAN, elle ne passe pas par OPNsense, les paquets sont directement switchés.

___
## Etape 3 : Bloquer l'attaquant
Comme les scans vers les machines du LAN ne pouvant pas être détecté par le pare-feu, nous ne pouvons qu'établir une règle bloquant l'attaquant du pare-feu :

![Pasted image 20251223155806](../Images/Pasted%20image%2020251223155806.png)

> Ne pas oublier d'activer le logging

Sauvegardons et appliquons les changements. 
La règle en premier lieu pour respecter le principe du **First Match Wins** :

![Pasted image 20251223160949](../Images/Pasted%20image%2020251223160949.png)

En refaisant le scan nmap depuis le Kali nous pouvons observer qu'il a été bloqué via notre nouvelle règle :

![Pasted image 20251223160017](../Images/Pasted%20image%2020251223160017.png)

___

# Phase 3 : IDS avec Suricata

Dans un réseau, le pare-feu analyse tout le trafic **passant par ses interfaces** en se basant sur les **adresses IPs** , les **ports** et les  **protocoles**. Cependant il ne fait pas une analyse du contenu des paquets. C'est là qu'intervient l'**IDS** (Intrusion Detection System) qui lui inspecte chaque **paquet**, inspecte leur **signature**, et **alerte ou bloque** les **paquets**.

Dans cette phase nous allons :
- Configurer **Suricata**, qui est un IDS, sur **OPNsense**
- Faire une reconnaissance du réseau avec Kali Linux
- **Observer** et **réagir**

___

## Etape 1 : Configuration de Suricata

### **Activation de Suricata sur l'interface LAN**
Pour activer **Suricata** sur la LAN, allons dans *Services > Intrusion Detection > Administration*,cochons **Enabled** puis sélectionnant le **LAN** comme interface :

![Pasted image 20251226112744](../Images/Pasted%20image%2020251226112744.png)

Puis **Save** 

![Pasted image 20251226112830](../Images/Pasted%20image%2020251226112830.png)

Maintenant, notre **IDS** est démarré cependant ne fait rien. **Pourquoi ?** Parce qu'il ne dispose pas de règles à utiliser pour analyser le trafic.

**Téléchargement des règles**

Pour télécharger les règles, toujours rester dans *Services > Intrusion Detection > Administration* puis aller dans **Download** et télécharger :
- **ET open/emerging-icmp**
-  **ET open/emerging-icmp_info**
-  **ET open/emerging-scan**
-  **ET open/emerging-polici**

![Pasted image 20251226203142](../Images/Pasted%20image%2020251226203142.png)

Allons dans **Rules** et assurons-nous que les règles concernant les scans nmap sont activées (dans le but de détecter les attaques dans la prochaine étape) :

![Pasted image 20251226204237](../Images/Pasted%20image%2020251226204237.png)

Puis **Apply**

![Pasted image 20251226204309](../Images/Pasted%20image%2020251226204309.png)

___

## Etape 2 : Reconnaissance et observation

Depuis notre Kali Linux effectuons un scan aggressif sur le pare-feu 

```sh
nmap -sCV -Pn 192.168.1.1
```

Et regardons les alertes

![Pasted image 20251226210020](../Images/Pasted%20image%2020251226210020.png)

Suricata génère des alertes d'un possible scan nmap. Examinons-la de près :

![Pasted image 20251227154704](../Images/Pasted%20image%2020251227154704.png)

Nous observons bien ici que l'alerte a été générée parce que le contenu d'un paquet HTTP avait comme header **user-agent**  contenant "Nmap Scripting Engine; https://nmap.org/book/nse.html"

**Contraintes**
Suricata  ici ne peut voir et analyser tout le trafic de notre réseau virtuel à cause de quelques contraintes techniques. Il n'écoute et ne capture les paquets passent que par l'interface d'OPNsense, il ne peut analyser les paquets envoyer entre les machines du LAN. 

___





