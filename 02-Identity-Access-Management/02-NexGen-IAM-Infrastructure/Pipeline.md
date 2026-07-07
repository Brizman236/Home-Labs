---
title: "Lab 2 : Gestion des Autorisations (RBAC) avec Keycloak et Nextcloud"
date: 2026-06-01
tags: ["IAM", "Keycloak", "FreeIPA", "Nextcloud", "RBAC", "OIDC"]
series: ["NexGen Infrastructure IAM"]
ShowToc: true
TocOpen: true
---

## 1. Contexte d'Entreprise & Objectif Métier (NexGen)
### Situation Actuelle
Dans le **Lab 1**, nous avons validé le socle d'authentification unique (SSO) de NexGen pour nos outils techniques (Gitea, Grafana). Les identifiants sont centralisés, mais un nouvel enjeu de sécurité apparaît avec l'arrivée d'une application collaborative transverse.

### Le Problème Métier
La direction de NexGen déploie **Nextcloud** pour le partage de fichiers. Cependant, laisser tous les employés accéder à l'ensemble des documents viole le principe du moindre privilège. Les données des Ressources Humaines ne doivent pas être visibles par les équipes techniques, et vice-versa.

### L'Objectif du Lab 2
Faire évoluer l'infrastructure existante pour implémenter une gestion des accès basée sur les rôles (**RBAC**). L'accès aux dossiers Nextcloud doit être automatiquement restreint et provisionné à la volée en fonction du département de l'utilisateur, sans gestion locale des permissions.

---

## 2. Cartographie des Flux & Architecture NexGen
*Rappel : Nextcloud s'appuie sur le cluster Keycloak et l'annuaire FreeIPA déjà en place.*

### Matrice des Droits et Accès (RBAC)
| Utilisateur de Test | Groupe FreeIPA | Rôle Keycloak | Périmètre / Stockage Nextcloud |
| :--- | :--- | :--- | :--- |
| `alice` | `dev-empl` | `role_dev` | Accès exclusif au dossier "NexGen-Dev" |
| `bob` | `hr-empl` | `role_hr` | Accès exclusif au dossier "NexGen-RH" |

---

## 3. Étape 1 : Évolution de l'Annuaire (FreeIPA)
*Cette étape enrichit la source de vérité établie au Lab 1.*
- Création des groupes d'utilisateurs métiers : `hr-empl` et `dev-empl`.
- Provisioning des profils de tests (Alice et Bob).
- *Partage des commandes CLI `ipa group-add` ou captures d'écran de l'interface FreeIPA.*

---

## 4. Étape 2 : Extraction et Transmission des Rôles (Keycloak)
- Configuration de la synchronisation des nouveaux groupes depuis FreeIPA via le User Federation LDAP.
- Création d'un **Client Scope** dédié dans Keycloak et configuration d'un *Group Membership Mapper*.
- Objectif : Injecter l'appartenance aux groupes dans le jeton **JWT (ID Token / Access Token)** transmis à Nextcloud.

---

## 5. Étape 3 : Intégration de Nextcloud dans l'Écosystème
- Déploiement de Nextcloud via Docker/Podman (raccordé au réseau existant).
- Installation de l'application d'authentification OpenID Connect (`user_oidc`).
- Configuration de la liaison avec le client OIDC de Keycloak.

---

## 6. Défi Terrain & Résolution : Le Mapping des Groupes
*(C'est ici que tu montres tes compétences de debug !)*
- **Le Problème :** Pourquoi l'application Nextcloud a initialement rejeté ou ignoré les rôles présents dans le jeton JWT.
- **La Solution :** Ajustement de la configuration des attributs OIDC ou utilisation de l'application *Group Provisioning* pour forcer la création et l'assignation automatique des groupes à la volée (*Just-In-Time*).

---

## 7. Validation SecOps (Cas Réels)
Preuves de la stricte étanchéité des accès :
- **Scénario A :** Connexion de l'ingénieur `alice` -> Vérification de la création automatique de son compte et de son accès unique au dossier "Dev".
- **Scénario B :** Connexion de l'agent RH `bob` -> Vérification qu'il est banni des répertoires techniques.

---

## 8. Conclusion & Prochaine Étape
Bilan sur la centralisation du contrôle d'accès au niveau de l'IdP. Ouverture sur le **Lab 3**, qui se concentrera sur le durcissement de la sécurité (MFA/TOTP et Password Policies) pour protéger ces accès métiers critiques.