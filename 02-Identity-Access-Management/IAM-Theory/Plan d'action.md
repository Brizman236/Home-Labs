Ici je vais détailler la manière avec laquelle je vais m'y prendre pour entrer dans le domaine.

## 1. Le Socle Technique : Les "Trois mousquetaires" de l'identité

L'IAM n'est pas limité à la création des utilisateurs, je dois apprendre et maîtriser les protocoles qui permettent aux machines, aux systèmes d'interagir sans échanger des mots de passe en clair. Nous avons :
- **le SALM 2.0** pour **Security Assertion Langage Markup** : c'est le standart pour le SSO en entreprise. Je dois apprendre comment un Identity Provider (idP) discute avec un Service Provider (SP) via des **fichiers XML**
- **OAuth & OpenID Connect** : Le langage moderne des APIs et des applications modernes.
- **LDAP & Kerberos** : Je dois apprendre comment les objets sont structurés dans l'AD et comment les tickets d'authentification circulent sur le réseau

___
## 2. Maîtriser les outils du marché

- **Cloud Identity** : Microsoft Entra ID et Okta
- **Privilege Access Management** : Concepts de coffre fort de mot de passe et de monitoring de session avec des outils comme **CyberArk** ou **Wallix**
- **Identity Governance and Administration** : Comment automatiser les arrivées/départs avec des solutions comme **SailPoint** ou **Saviynt**.

___

## 3. Le Mindset : au delà de la technique

L'IAM n'est pas que de la configuration mais aussi de l'architecture basée sur de la logique :
- **RBAC & ABAC** : L'on doit savoir quand attribuer des droits en se basant sur le rôle (Ex: Comptable) ou sur des attributs (Ex: Eric, bureau de Dakar, le lundi uniquement)
- **Conformité et Audit** : L'IAM est le meilleur ami des auditeurs, il faut pouvoir générer des rapports montrant que personne n'a de droits inutiles
- **Automatisation** : Bash, Powershell, Python

___

## 4. Ton Plan d'Action Pratique

### Étape 1 : Le Lab "Modern IAM"

Ne te contente pas de ton AD local.

1. Crée un compte gratuit **Azure/Entra ID** ou un tenant développeur **Okta**.
    
2. Essaie de monter un SSO entre ton IdP Cloud et une application simple (comme un WordPress ou un outil de ticketing open-source).
    
3. Utilise tes compétences en PKI pour configurer une authentification par certificat (SBA - Smartcard Based Auth) sur ton tenant.
    

### Étape 2 : Les Certifications "Porte-Drapeau"

Pour rassurer un recruteur quand on est junior :

- **SC-300 (Microsoft Identity and Access Administrator) :** LA référence actuelle pour Entra ID.
    
- **Okta Certified Professional :** Très valorisé pour le monde du SaaS.
    
- **ISC2 Certified in Cybersecurity (CC) :** Pour la base globale si tu ne l'as pas encore.
    

### Étape 3 : Documentation & Veille

Documente tes tests de lab. Un blog technique ou un GitHub bien tenu montrant comment tu as intégré une application avec OAuth2 vaut mille CV.

**Le petit plus qui fait la différence ?** Intéresse-toi à la **Souveraineté des données**. Dans un contexte où l'on déploie des solutions de confiance (comme pour des signatures de diplômes ou des infrastructures critiques), savoir où sont stockées les identités est un argument majeur pour un consultant junior.

Qu'est-ce qui te semble le plus complexe à aborder dans cette liste : les protocoles (SAML/OIDC) ou la gestion des outils Cloud ?