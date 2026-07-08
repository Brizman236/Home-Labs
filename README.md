# 🛡️ Cybersecurity Labs — Portfolio de Labs en Cybersécurité

Bienvenue dans mon dépôt de **labs pratiques en cybersécurité**.

Ce dépôt regroupe l'ensemble de mes travaux pratiques organisés par **domaine de compétences**. Chaque dossier correspond à un pilier de la cybersécurité offensive et défensive : **sécurité réseau, gestion des identités et des accès (IAM), cryptographie & PKI**, et **détection d'incidents (Detection Engineering)**.

L'objectif est de **mettre en pratique des concepts théoriques** dans des environnements virtualisés réalistes, et de documenter chaque lab de manière claire et reproductible.

---

## 📂 Structure du dépôt

```
.
├── 01-Network-Security/          # Sécurité réseau (pare-feu, IDS/IPS, DNS)
├── 02-Identity-Access-Management/# Gestion des identités et des accès (AD, IAM, Cloud)
├── 03-PKI-Cryptography/          # PKI, certificats TLS, signatures numériques
├── 04-Detection-Engineering/     # SIEM, détection d'incidents, Threat Hunting
└── Images/                       # Captures d'écran utilisées dans la documentation
```

---

## 🗂️ Catalogue des labs

### 01 — 🌐 Network Security

| Lab | Description |
|-----|-------------|
| [**OPNsense & Suricata**](01-Network-Security/01-OPNsense-Firewall/README.md) | Installation et configuration d'un pare-feu **OPNsense**, création de règles de filtrage (First Match Wins), lecture de logs firewall, et déploiement d'un **IDS Suricata** pour l'analyse du trafic. |
| [**Serveur DNS Bind9**](01-Network-Security/02-DNS-Server-Bind9/README.md) | Mise en place d'un serveur **DNS** avec **Bind9** : résolution de noms, zones, et sécurisation. |

---

### 02 — 🔑 Identity & Access Management (IAM)

| Lab | Description |
|-----|-------------|
| [**Active Directory**](02-Identity-Access-Management/01-Active-Directory/README.md) | Déploiement d'un **Domain Controller Windows Server**, gestion des OU/utilisateurs, **tests de pénétration** avec Kali Linux, et **hardening via GPO**. |
| [**NexGen IAM Infrastructure**](02-Identity-Access-Management/02-NexGen-IAM-Infrastructure/) | Mise en place d'une infrastructure **IAM moderne** : approche pipeline, étapes et labs pratiques. |
| [**Hybrid Cloud Entra ID**](02-Identity-Access-Management/03-Hybrid-Cloud-EntraID/Documentation.md) | Intégration d'un environnement **hybride** : Active Directory on-premise synchronisé avec **Microsoft Entra ID** (Azure AD). |
| [**IAM Theory**](02-Identity-Access-Management/IAM-Theory/) | Modules théoriques sur l'IAM : authentification, autorisation, JML (Joiner/Mover/Leaver), roadmap et plan d'action. |

---

### 03 — 🔐 PKI & Cryptography

| Lab | Description |
|-----|-------------|
| [**PKI & TLS**](03-PKI-Cryptography/01-PKI-TLS/Partie%201.md) | Déploiement d'une **Infrastructure à Clés Publiques (PKI)**, émission de certificats, configuration **TLS**, et gestion des **CRL / OCSP**. |
| [**PKI & Digital Signature**](03-PKI-Cryptography/02-PKI-Digital-Signature/Documentation.md) | Mise en pratique de la **signature numérique** : signature, vérification, et non-répudiation. |
| [**Python PKI**](03-PKI-Cryptography/03-Python-PKI/Docs.md) | Implémentation programmatique de concepts PKI avec **Python**. |

---

### 04 — 🔎 Detection Engineering

| Lab | Description |
|-----|-------------|
| [**Wazuh + Sysmon + Atomic Red Team**](04-Detection-Engineering/01-Wazuh-Sysmon-Detection/README.md) | Déploiement d'un **SIEM Wazuh**, collecte de logs Windows enrichis via **Sysmon**, simulation d'attaques avec **Atomic Red Team**, et analyse d'alertes corrélées avec **MITRE ATT&CK**. |

---

## 🛠️ Environnement & Outils

Tous les labs sont réalisés dans des environnements **virtualisés** (VMware / VirtualBox / Proxmox), avec les technologies suivantes :

- **Réseau :** OPNsense, Suricata, Bind9, Wireshark
- **Systèmes :** Windows Server, Windows 10/11, Ubuntu Server, Kali Linux
- **Identité :** Active Directory, Microsoft Entra ID, GPO
- **PKI :** OpenSSL, ADCS, Python (cryptography)
- **Détection :** Wazuh, Sysmon, Atomic Red Team, MITRE ATT&CK

---

## 📌 Convention de nommage

Les dossiers sont numérotés (`01-`, `02-`, ...) pour refléter une **progression logique** entre les domaines. Chaque lab contient généralement :

- un **`README.md`** — présentation, objectifs et architecture
- un ou plusieurs **fichiers de documentation** détaillés — étapes, commandes, captures d'écran

---

## 📖 Comment naviguer

1. Choisissez un **domaine** dans le catalogue ci-dessus.
2. Ouvrez le **`README.md`** du lab pour comprendre ses objectifs et son architecture.
3. Suivez la **documentation détaillée** pour reproduire le lab.

---

> 💡 *Ce dépôt est un espace d'apprentissage continu. Les labs sont régulièrement enrichis et mis à jour.*
