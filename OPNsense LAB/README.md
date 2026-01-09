
# 🛡️ LAB – Sécurisation d’un réseau avec OPNsense & Suricata

## 📌 Objectif du LAB

Dans un contexte où les systèmes informatiques sont de plus en plus exposés aux cyberattaques, la sécurisation des infrastructures réseau est devenue une compétence clé en cybersécurité.

Ce LAB a pour objectif de **mettre en pratique les fondamentaux de la sécurité réseau** à travers l’installation et la configuration d’un **pare-feu OPNsense**, l’analyse du trafic réseau, et la mise en place d’un **IDS (Suricata)**.

---

## 🎯 Compétences abordées

À la fin de ce LAB, vous serez capable de :

- Installer et configurer un **pare-feu OPNsense**
    
- Comprendre la différence entre **WAN, LAN et NAT**
    
- Créer et ordonner des **règles de pare-feu**
    
- Comprendre le principe **First Match Wins**
    
- Lire et interpréter des **logs firewall**
    
- Simuler des **attaques réseau**
    
- Déployer et analyser un **IDS avec Suricata**
    

---

## 🧪 Structure du LAB

Le LAB est divisé en **3 phases** :

1. **Prise en main d’OPNsense**
    
2. **Attaque & Défense (Firewall & Logs)**
    
3. **Détection d’intrusion avec Suricata**
    

---

## 🖥️ Environnement technique

### Logiciel de virtualisation

- **VMware Workstation**
    

### Réseaux virtuels

|VMnet|Type|Rôle|
|---|---|---|
|VMnet8|NAT|WAN (Internet)|
|VMnet2|Host-Only|LAN (Interne)|

### Machines virtuelles

|VM|Interfaces|Réseaux|
|---|---|---|
|OPNsense|2 NIC|WAN (VMnet8) + LAN (VMnet2)|
|Client Ubuntu|1 NIC|LAN (VMnet2)|
|Kali Linux (Attaquant)|1 NIC|LAN (VMnet2)|

---

## 🗺️ Topologie du LAB

![Pasted image 20260109084945](../Images/Pasted%20image%2020260109084945.png)

---

## 🔹 Phase 1 – Prise en main d’OPNsense

- Installation d’OPNsense
    
- Accès à l’interface Web
    
- Découverte du tableau de bord
    
- Compréhension et manipulation des **règles de pare-feu**
    
- Mise en évidence du principe **First Match Wins**
    

---

## 🔹 Phase 2 – Attaque & Défense

### Attaques simulées

- Scan réseau avec **Nmap**
    
- Découverte des hôtes actifs
    
- Identification des services exposés
    

### Défense

- Activation du **logging**
    
- Lecture des logs en temps réel
    
- Analyse du trafic entrant
    
- Blocage ciblé d’un attaquant via règle firewall
    

---

## 🔹 Phase 3 – IDS avec Suricata

- Activation de **Suricata** sur l’interface LAN
    
- Téléchargement et activation des règles **Emerging Threats**
    
- Détection des scans Nmap
    
- Analyse des alertes générées
    
- Compréhension des limites de visibilité IDS en environnement LAN
    

---

## ⚠️ Limites observées

- Le pare-feu et l’IDS ne peuvent analyser que le trafic **passant par leurs interfaces**
    
- Le trafic **LAN → LAN** n’est pas inspecté sans architecture spécifique (SPAN, bridge, TAP, etc.)
    

---

## 🧠 Points clés retenus

- Un pare-feu **ne suffit pas seul**
    
- L’ordre des règles est **critique**
    
- Le logging est indispensable pour la détection
    
- IDS ≠ Firewall (analyse du **contenu**, pas seulement des métadonnées)
    
- La visibilité réseau dépend fortement de l’architecture
    

---

## 🚀 Perspectives d’amélioration

- Activer le mode **IPS**
    
- Ajouter une segmentation réseau (VLAN)
    
- Centraliser les logs (SIEM)
    
- Simuler des attaques plus avancées
    
- Ajouter des règles personnalisées Suricata
    

---

## 👤 Auteur

**Eric Yawilhit**  
Étudiant en cybersécurité  
Objectif : Ingénieur / Architecte Cybersécurité  
Orientation : **SOC – Detection Engineering – Blue Team**

---

🧪 _Learn by breaking. Secure by understanding._
