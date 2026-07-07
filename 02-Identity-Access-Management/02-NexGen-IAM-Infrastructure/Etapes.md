- **Lab 1 (En cours) :** Base du SSO (Keycloak + FreeIPA + Gitea + Grafana).
    
### Lab 3 : La Migration Hybride et l'Accès Conditionnel (Workforce IAM)

- **L'objectif technique :** Déployer **Microsoft Entra ID** (via le programme dev gratuit) et interconnecter ton infrastructure locale existante (FreeIPA/Keycloak) avec le Cloud.
    
- **Le problème métier :** Les commerciaux sur le terrain ont besoin d'accéder aux applications, mais la direction panique à l'idée d'ouvrir les accès sur Internet. Le MFA classique ne suffit plus.
    
- **Ce que tu vas implémenter :**
    
    - Mise en place d'une fédération ou d'une synchronisation entre ton Keycloak/FreeIPA et Entra ID.
        
    - Configuration de l'**Accès Conditionnel** (le roi de l'ABAC sur le marché) : interdire l'accès si l'utilisateur se connecte depuis un pays hors Europe, ou s'il n'utilise pas un appareil validé.
        

### Lab 4 : Le rachat d'entreprise et le multi-tenant (B2B & Fédération)

- **L'objectif technique :** Utiliser **Okta Developer** ou **Auth0** pour simuler une autre entreprise.
    
- **Le problème métier :** NexGen rachète une startup. Ses ingénieurs doivent accéder immédiatement à ton Gitea ou ton Nextcloud, mais il est hors de question de recréer leurs comptes un par un dans ton FreeIPA ou ton Entra ID.
    
- **Ce que tu vas implémenter :** Une fédération d'identité B2B entre le tenant Okta (la startup) et ton tenant Entra ID ou Keycloak (NexGen). Un ingénieur de la startup se connectera avec ses propres identifiants et sera reconnu automatiquement chez NexGen.
    

### Lab 5 : La Gouvernance et le cycle de vie (L'introduction à l'IGA)

- **L'objectif technique :** Découvrir la gestion des identités automatisée (le protocole **SCIM** utilisé par SailPoint ou Okta).
    
- **Le problème métier :** Le turnover augmente chez NexGen. Les RH oublient souvent de signaler les départs des stagiaires, laissant des "comptes fantômes" actifs et vulnérables. De plus, les développeurs accumulent des droits au fil des projets sans jamais les perdre.
    
- **Ce que tu vas implémenter :** Automatiser le cycle de vie (Joiner/Mover/Leaver). Tu utiliseras des workflows (via Okta Workflows ou l'automatisation Entra ID) pour que la création d'un utilisateur déclenche automatiquement son provisionnement SCIM dans les applications, et que sa désactivation coupe tout instantanément.