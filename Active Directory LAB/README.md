# 🔎 LAB – Active Directory : Déploiement, Pentest & Hardening

## 📌 Contexte & Objectifs

Ce lab consiste à mettre en place un **domaine Active Directory** avec un **Domain Controller**, une machine cliente **Windows** et une machine **Kali Linux** pour les tests offensifs.

L’objectif principal est de comprendre **comment un domaine AD est configuré, comment ses failles peuvent être exploitées, et comment le durcir via les GPO**.

---

## 🎯 Objectifs pédagogiques

À l’issue de ce lab, vous serez capable de :

- Installer et configurer un **Domain Controller Windows Server**
    
- Créer et organiser des **Unités d’Organisation (OU)**
    
- Ajouter et gérer des **machines et utilisateurs dans le domaine**
    
- Réaliser des **tests de pénétration basiques** sur AD
    
- Identifier les **faiblesses liées aux configurations par défaut**
    
- Appliquer un **hardening via GPO** pour sécuriser le domaine
    

---

## 🧪 Architecture du LAB

### Machines virtuelles

|VM|OS|Rôle|
|---|---|---|
|DC1|Windows Server|Domain Controller / AD|
|WIN10-CLIENT|Windows 10|Client du domaine|
|KALI-LINUX|Kali Linux|Machine offensive / Pentest|

---

## 🗺️ Topologie du LAB


![[WhatsApp Image 2025-12-04 at 16.16.28.jpeg]]

---

## 🧱 Phase 1 – Mise en place et configuration du domaine

### Objectifs

- Déployer un **Active Directory fonctionnel**
    
- Créer des **OU** et des comptes utilisateurs
    
- Intégrer la machine cliente au domaine
    

### Étapes principales

- Installation du **Domain Controller Windows Server**
    
- Création du domaine `cyber.lab`
    
- Création des OU : `ADMINS`, `USERS`, `COMPUTERS`
    
- Ajout des comptes utilisateurs et administrateurs
    
- Intégration de la machine **WIN10-CLIENT** au domaine
    

📌 **Résultat attendu** : Un domaine AD fonctionnel avec utilisateurs et postes intégrés.

---

## ⚔️ Phase 2 – Tests de pénétration

### Objectifs

- Identifier les failles liées aux **paramètres par défaut**
    
- Énumérer les utilisateurs et machines du domaine
    
- Tester les **mots de passe faibles**
    
- Réaliser une **escalade de privilèges** et accéder au Domain Controller
    

### Scénarios inclus

- Énumération avec **Kerbrute et sessions null**
    
- ASREP-Roasting pour utilisateurs sans pré-authentification
    
- Brute-force des mots de passe faibles
    
- Escalade et prise de contrôle via **Evil-WinRM**
    

📌 **Résultat attendu** : Compréhension des risques AD en environnement non durci.

---

## 🔐 Phase 3 – Hardening du domaine AD

### Objectifs

- Réduire la **surface d’attaque**
    
- Sécuriser les comptes utilisateurs et machines
    
- Appliquer des **GPO de sécurité**
    

### Mesures mises en place

- **Password Policy** : mots de passe longs, complexes et durée minimale/maximale définie
    
- **Account Lockout Policy** : verrouillage des comptes après plusieurs tentatives échouées
    
- **Security Options** : désactivation des authentifications faibles, comptes inutiles et stockage de hachages vulnérables
    

📌 **Résultat attendu** : Un domaine AD durci, résistant aux attaques basiques de brute-force et password spraying.

---

## ✅ Résultats obtenus

- Domaine Active Directory fonctionnel avec comptes et OU
    
- Vulnérabilités liées aux configurations par défaut identifiées
    
- Escalade de privilèges simulée avec succès
    
- Hardening via GPO appliqué et vérifié
    
- Compréhension pratique des mécanismes offensifs et défensifs dans AD
    

---

## ⚠️ Limites actuelles

- Tests de pénétration limités aux comptes et mots de passe faibles
    
- Pas de scénarios avancés de mouvement latéral ou persistance
    

---

## 🚀 Pistes d’amélioration

- Déploiement de **scénarios de pass-the-hash et relay NTLM**
    
- Tests sur **mouvements latéraux**
    
- Mise en place de **surveillance SIEM pour AD**
    
- Automatisation des GPO et audits réguliers
    

---

## 🧠 Leçon clé

> Comprendre les **attaques sur AD** est indispensable pour déployer des **contre-mesures efficaces et un environnement sécurisé**.

---

## 👤 Auteur

**Eric Yawilhit**  
Étudiant en cybersécurité  
Objectif : Ingénieur / Architecte Cybersécurité  
Orientation : **SOC – Detection Engineering – Blue Team**

---

🛡️ _Understanding AD attacks is the first step to securing it effectively._
