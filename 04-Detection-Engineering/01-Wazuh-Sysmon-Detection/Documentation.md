___

# Introduction - Contexte & Objectifs du lab

Ce lab s'inscrit dans une démarche d'apprentissage de la **détection des incidents dans un environnement Windows**. Il vise à comprendre comment les évènements systèmes peuvent être collectés et analysés dans un **SIEM**. 

L'**objectif principal** de ce lab est de mettre en place une **pipeline de détection fonctionnelle**, depuis la génération des logs jusqu'à l'analyse des alertes.

Le lab a aussi pour objectifs :
- La prise en main de **Wazuh**
- La **configuration** de la collecte d'évènement Windows
- La compréhension de la différence entre un **log** et une **alerte**

___

## Phase 1 : Validation de l’environnement

Cette phase a pour but de mettre en place notre environnement de détection. 
Nous allons :
- Installer les machines virtuelles : Windows 10, Ubuntu Server
- Installer Wazuh et Wazuh Agent 
- Installer Sysmon sur le client windows
- Installer l'outil **Atomic Red Team** sur le client Windows

___

### Etape 1 : Installation des machines virtuelles

####  🖥️ VM 1 – Windows Endpoint (Machine attaquée)

**Spécifications**

- OS : Windows 10
    
- RAM : 4 Go  
    
- CPU : 2 vCPU  
    
- Rôle : **Endpoint surveillé**  
    
---

#### 🐧 VM 2 – Wazuh Sercer + Indexer + Dashboard (SOC Core)

**Spécifications**

- OS : Ubuntu Server  
    
- RAM : 4 Go  
    
- CPU : 2vCPU  
    
- Rôle : **Centre de détection SOC**

___

### Etape 2 :  Installation de Wazuh et de Wazuh Agent sur WIN-10

**Wazuh** est une **plateforme open source de sécurité** qui permet de **collecter, analyser et corréler des logs** afin de **détecter des incidents de sécurité**, surveiller l’intégrité des systèmes et générer des **alertes** à partir de règles de détection. C'est le coeur de notre lab.

Wazuh récupère les logs depuis des postes grâce au Wazuh Agent installé sur chaque poste collectant les logs et les envoyant au Wazuh Manager.

**Installation de Wazuh et de ses composants** 

- Démarrons les VMs **Ubuntu Server**  puis accédons au serveur via **SSH** 
- Téléchargeons le script de l'assistant d'installation de **Wazuh** 
```sh
	curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh	
```
- Lançons le script en mode root :
```sh
	sudo bash wazuh-install.sh -a
```

- À la fin de l'installation, nous aurons un les identifiants de connexions affichés dans la console, nous allons accéder à l'interface WEB  depuis notre navigateur et entrer les identifiants :
		![Pasted image 20260104124823](../../Images/Pasted%20image%2020260104124823.png)

> **Wazuh est installé.**

**Installation de l'agent Wazuh sur le client Windows**

L'agent Wazuh est un logiciel que l'on installe sur un client, et son rôle sera de collecter les logs du client en question puis de les envoyer au Wazuh Manager. Pour cela, le Wazuh Agent devra connaître l'adresse IP du Wazuh Mananger, de ce fait l'adresse IP de ce dernier devra être fixe, statique. 

Avant de commencer l'installation du Wazuh-Agent, nous allons d'abord configurer une adresse IP statique à notre server avec `netplan` :
- D'abord identifier l'interface réseau :
		![Pasted image 20260104125501](../../Images/Pasted%20image%2020260104125501.png)
	qui est `ens33` dans notre cas ici
- Chercher le fichier de configuration qui est dans `/etc/netplan` :
	   ![Pasted image 20260104125705](../../Images/Pasted%20image%2020260104125705.png)=
-    Faire cette configuration
```yaml
network:
  version: 2
  ethernets:
	ens33:
	  dhcp4: no
	  addresses: [192.168.38.100/24]
	  routes:
		- to: default
		  via: 192.168.38.1
```

-  Sauvegarder, quitter puis appliquer avec :  `sudo netplan apply`

> L'adresse a été fixée

Maintenant nous pouvons déployer notre agent :
- Depuis l'accueil cliquer sur le bouton *Deploy new agent*
		![Pasted image 20260104130622](../../Images/Pasted%20image%2020260104130622.png)
		

- Cocher le système Windows, entrer l'adresse IP du server puis nommer l'Agent 
		![Pasted image 20260104130905](../../Images/Pasted%20image%2020260104130905.png)
- Copier la première commande et la coller dans PowerShell (En mode Administrateur) sur le client Windows
		![Pasted image 20260104171312](../../Images/Pasted%20image%2020260104171312.png)
		
- Puis la deuxieme commande
		![Pasted image 20260104171250](../../Images/Pasted%20image%2020260104171250.png)

De retour sur la liste des agents sur l'interface WEB, on remarquera notre agent **Windows10** 👇 

![Pasted image 20260104171525](../../Images/Pasted%20image%2020260104171525.png)

___

### Etape 3 : Installation de Sysmon sur le client Windows 10 et son intégration à Wazuh

**Sysmon (System Monitor)** est un outil de Microsoft qui **enregistre des événements de manière détaillée sur l’activité d’un système Windows** (processus, connexions réseau, fichiers, etc.) . Elle nous permettra ici de récupérer des logs précis, détaillés sur presque tous les évènements  bas-niveau de Windows .

Suivons ces étapes pour l'installation et l'intégration:
- Aller sur la documentation officielle de **Sysmon**  https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon puis télécharger **Sysmon** :
		![Pasted image 20260105005647](../../Images/Pasted%20image%2020260105005647.png)
- Extraire le fichier ZIP
		![Pasted image 20260105010137](../../Images/Pasted%20image%2020260105010137.png)
- Acceder au fichier depuis PowerShell (en mode Administrateur) puis installons Sysmon
	![Pasted image 20260105010815](../../Images/Pasted%20image%2020260105010815.png)
> Sysmon a bien été installé

Ouvrons l'**Observateur des évènements** pour vérifier si les logs **Sysmon** sont présents. 
En général, on le trouve dans *Journaux des applications et des services > Microsoft > Windows > Sysmon > Operational* 
![Pasted image 20260105014751](../../Images/Pasted%20image%2020260105014751.png)

**Intégration des Logs Sysmon à Wazuh**

Pour que nous puissons avoir les logs depuis notre interface Wazuh, nous devons configurer l'agent de telle sorte qu'il collecte les logs Sysmon. Pour cela, nous devons éditer le fichier de configuration de l'agent  `C:\Program Files (x86)\ossec-agent\ossec.conf` et ajouter ce code dans la section  `ossec_config` :

```xml
<localfile>
  <location>Microsoft-Windows-Sysmon/Operational</location>
  <log_format>eventchannel</log_format>
</localfile>
```

![Pasted image 20260105020011](../../Images/Pasted%20image%2020260105020011.png)

Cette configuration permettra à l'agent de " s'abonner " au journal de logs Windows, et plus précisément à celui de **Sysmon** grâce aux **APIs Windows** (`EvtSubscribe` et `EvtQuery`). Le format  `eventchannel` sert à spécifier que ce seront des logs provenant de Canal d'évènement Windows, ce qui facilitera le décodage et le parsing.

Nous allons enregistrer les modifications et redémarrer l'agent avec :

```powershell
Restart-Service -Name WazuhSvc
```

Pour vérifier si Wazuh Server a bien reçu les logs provenant de sysmon, nous devons nous rendre sur *Explore > Discover* et appliquer le filtre :

![Pasted image 20260106072211](../../Images/Pasted%20image%2020260106072211.png)

Nous aurons alors les logs fournis par **Sysmon** :

![Pasted image 20260106072303](../../Images/Pasted%20image%2020260106072303.png)

___

### Etape 4 : Installation d'Atomic Red Team sur le client Windows

**Atomic Red Team** est une **suite de tests d’attaque légers et contrôlés** qui permet de **simuler des techniques MITRE ATT&CK** sur un système afin de **tester et valider les capacités de détection** (EDR, SIEM, Wazuh, etc.), **sans infrastructure d’attaque complexe**.

> Assurons-nous de désactiver Windows Defender avant de procéder à l'installation.

Il s'installe comme un module PowerShell :

```powershell
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing)
Install-AtomicRedTeam -getAtomics -Force
```

Pour éviter l'importation du module à chaque nouvelle session PowerShell,  nous allons ajouter l'importation dans le profil :

```powershell
# Ouvrons le fichier profil
notepad $profile

# Copions-y le code ci-dessous
Import-Module "C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force
$PSDefaultParameterValues = @{"Invoke-AtomicTest:PathToAtomicsFolder" = "C:\AtomicRedTeam\atomics"}

# Enregistrons, fermons le fichier puis relançons PowerShell
```

Dans la majorité des cas, nous aurons une erreur concernant l'**Execution Policy** qui bloque l'execution de script :

![Pasted image 20260106075206](../../Images/Pasted%20image%2020260106075206.png)

De ce fait, nous allons changer l'**Execution Policy** pour que notre profil soit chargé (à le faire dans un environnement contrôlé) :

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

Après le relancement de PowerShell, notre profil se charge avec succès :

![Pasted image 20260106075925](../../Images/Pasted%20image%2020260106075925.png)

Vérifions maintenant avec :

```powershell
Invoke-AtomicTest T1003 -ShowDetailsBrief
```

![Pasted image 20260106092840](../../Images/Pasted%20image%2020260106092840.png)

La phase 1 a été valider :
- Wazuh et Wazuh Agent installés et fonctionels
- Sysmon installé et fonctionel
- Atomic Red Team installé et fonctionnel

___

## Phase 2 : Exécution de commande locale

Après avoir mis en place notre **environnement de détection**, nous allons vérifier si ce dernier est en capacité de détecter un comportement malveillant simple, dans notre cas ici ce seront des exécutions suspectes de commandes.

Cette phase vise à :
- **Déclencher une vraie action malveillante contrôlée** 
- **Observer la création de processus côté endpoint**
- **Vérifier que Wazuh génère une alerte compréhensible** 
- **Apprendre à lire une ligne de commande comme un analyste SOC**

Nous allons utiliser la technique **MITRE ATT&CK**  **T1059** (Command and Scripting Interpreter)  :
- **T1059.003-3** : Suspicious Execution via Windows Command Shell 

____

### Scénario 1 – Suspicious Execution via Windows Command Shell (T1059.003-3)

Lançons le test avec :

```powershell
Invoke-AtomicTest T1059.003 -TestNumbers 3
```

![Pasted image 20260107093443](../../Images/Pasted%20image%2020260107093443.png)

**Analyse côté SOC**
- Sur **Discover**, nous observons un pic à **9h30** , cliquons sur ce pic:
	![Pasted image 20260107093726](../../Images/Pasted%20image%2020260107093726.png)
	![Pasted image 20260107094203](../../Images/Pasted%20image%2020260107094203.png)
	
- Nous remarquons là qu'aux alentours de 9h30, nous avons reçu des alertes concernant une exécution de commande

![Pasted image 20260108231545](../../Images/Pasted%20image%2020260108231545.png)

En analysant, l'alerte en détail nous observons :
- Processus parent : `cmd.exe`, c'est un processus légitime
-  `cmd /c`  -> exécution non intéractive,  ceci n'est pas habituel
- Dossier d'exécution `C:\\Users\\MRROBO~1\\AppData\\Local\\Temp\\`, pas habituel non plus. Cela commence a devenir suspect
- Obfuscation de l'interpréteur `%LOCALAPPDATA:~-3,1%md` qui cache `cmd`


Nous remarquons aussi que Wazuh a effectivement corrélé l'évènement en se basant sur le framework **MITRE ATT&CK** :

![Pasted image 20260108230358](../../Images/Pasted%20image%2020260108230358.png)


En résumé, une commande `cmd.exe` a été exécutée de manière non intéractive avec une obfuscation simple de l'interpréteur et dans un dossier inhabituel. Le comportement est compatible avec une exécution automatisée malveillante. L'impact est **limité**, il n'y a pas eu de **persistance** ni d'**élévation**. Le processus fut légitime mais pas son comportement.

____

## Conclusion

Ce lab a permis de mettre en place une **chaîne de détection complète et fonctionnelle** dans un environnement Windows, depuis la **génération d’un comportement malveillant contrôlé** jusqu’à son **analyse côté SOC via un SIEM**.

À travers l’installation et la configuration de **Wazuh**, de son **agent Windows**, de **Sysmon** et de **Atomic Red Team**, nous avons validé que :

- Les **événements bas niveau** du système (création de processus, lignes de commande, chemins d’exécution) sont correctement **collectés et centralisés**
    
- Wazuh est capable de **parser, corréler et enrichir les logs** Windows
    
- Une activité malveillante simple mais réaliste (T1059.003) peut être **détectée, contextualisée et reliée au framework MITRE ATT&CK**
    

L’exécution non interactive de `cmd.exe`, combinée à une **obfuscation légère** et à un **répertoire d’exécution inhabituel**, illustre parfaitement la différence entre un **processus légitime** et un **comportement suspect**. Ce lab met ainsi en évidence un point fondamental en cybersécurité défensive :

> **ce n’est pas l’outil qui est malveillant, mais la manière dont il est utilisé**.

Enfin, ce travail a renforcé la compréhension pratique de la distinction entre **logs** et **alertes**, ainsi que la méthodologie d’analyse adoptée par un **analyste SOC** : observer, contextualiser, corréler et qualifier l’impact réel d’un événement.

Ce lab constitue une **base solide** pour des scénarios plus avancés, incluant la **persistance**, l’**élévation de privilèges** ou les **mouvements latéraux**, et s’inscrit pleinement dans une démarche de montée en compétences en **détection et réponse aux incidents**.