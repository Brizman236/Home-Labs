# 🔎 LAB – Détection d’incidents Windows avec Wazuh, Sysmon & Atomic Red Team

## 📌 Contexte & Objectifs

Ce lab s’inscrit dans une démarche d’apprentissage de la **détection des incidents de sécurité dans un environnement Windows**.  
Il vise à comprendre **comment un comportement malveillant est généré, collecté, analysé et transformé en alerte exploitable** dans un **SIEM**.

L’objectif principal est de mettre en place une **pipeline de détection fonctionnelle**, depuis la **génération des logs bas niveau** jusqu’à leur **corrélation et analyse côté SOC**.

---

## 🎯 Objectifs pédagogiques

À l’issue de ce lab, vous serez capable de :

- Déployer un **SIEM Wazuh** fonctionnel
    
- Installer et configurer un **Wazuh Agent** sur Windows
    
- Collecter des **logs Windows enrichis avec Sysmon**
    
- Comprendre la différence entre **log** et **alerte**
    
- Simuler des comportements malveillants avec **Atomic Red Team**
    
- Analyser une **alerte SOC** et la relier à **MITRE ATT&CK**
    

---

## 🧪 Architecture du LAB

### Machines virtuelles

|VM|OS|Rôle|
|---|---|---|
|Windows 10|Windows|Endpoint surveillé|
|Wazuh Server|Ubuntu Server|SIEM (Manager + Indexer + Dashboard)|

---

## 🗺️ Topologie du LAB


![[Pasted image 20260109085420.png]]
---

## 🧱 Phase 1 – Validation de l’environnement

### Objectifs

- Déployer l’infrastructure SOC
    
- Vérifier la collecte des logs
    
- Valider les outils de détection
    

### Étapes principales

- Installation des machines virtuelles
    
- Installation de **Wazuh (Manager, Indexer, Dashboard)**
    
- Déploiement du **Wazuh Agent** sur Windows
    
- Installation et intégration de **Sysmon**
    
- Installation de **Atomic Red Team**
    

📌 **Résultat attendu** :  
Un endpoint Windows générant des logs détaillés, centralisés et visibles dans Wazuh.

---

## 🔐 Collecte et enrichissement des logs

### Sysmon

Sysmon permet de collecter des événements bas niveau :

- Création de processus
    
- Lignes de commande
    
- Connexions réseau
    
- Activités suspectes système
    

Les logs Sysmon sont intégrés à Wazuh via le **canal d’événements Windows**, permettant un **parsing précis et fiable**.

---

## ⚔️ Phase 2 – Détection d’exécution de commande (T1059)

### Objectifs

- Déclencher un comportement malveillant contrôlé
    
- Observer la création de processus
    
- Vérifier la génération d’alertes SOC exploitables
    
- Apprendre à lire une **ligne de commande comme un analyste SOC**
    

### Technique MITRE ATT&CK utilisée

- **T1059 – Command and Scripting Interpreter**
    
- **T1059.003 – Windows Command Shell**
    
- Test Atomic : _Suspicious Execution via cmd.exe_
    

---

## 🧠 Analyse SOC

L’alerte générée met en évidence :

- Une exécution **non interactive** de `cmd.exe`
    
- Une **obfuscation simple** de l’interpréteur
    
- Un **répertoire d’exécution inhabituel**
    
- Une corrélation avec **MITRE ATT&CK**
    

📌 Le processus est légitime, mais **son comportement ne l’est pas**.

---

## 📊 Différence clé : Log vs Alerte

- **Log** : événement brut généré par le système
    
- **Alerte** : log enrichi, corrélé et qualifié comme suspect
    

Ce lab démontre comment :

> un simple événement devient une **alerte SOC contextualisée**

---

## ✅ Résultats obtenus

- Collecte fiable des logs Windows bas niveau
    
- Intégration réussie de Sysmon dans Wazuh
    
- Détection d’un comportement malveillant réaliste
    
- Corrélation automatique avec MITRE ATT&CK
    
- Lecture et interprétation SOC-ready des alertes
    

---

## ⚠️ Limites actuelles

- Scénario volontairement simple (pas de persistance)
    
- Pas d’élévation de privilèges
    
- Pas de mouvement latéral
    

---

## 🚀 Pistes d’amélioration

- Détection de **persistance** (Run Keys, Services)
    
- Scénarios **Privilege Escalation**
    
- Corrélation multi-étapes
    
- Création de **règles personnalisées Wazuh**
    
- Simulation de **kill chain complète**
    

---

## 🧠 Leçon clé

> **Ce n’est pas l’outil qui est malveillant, mais la manière dont il est utilisé.**

---

## 👤 Auteur

**Eric Yawilhit**  
Étudiant en cybersécurité  
Objectif : Ingénieur / Architecte Cybersécurité  
Orientation : **SOC – Detection Engineering – Blue Team**

---


🛡️ _Detection is not about alerts, it’s about understanding behavior._

