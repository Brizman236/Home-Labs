## Les protocoles
### 1. Kerberos
C'est un protocol historique de Microsoft Active Directory, il facilite la communication sans échange de mot de passe. Il est basé sur un système di tickets :
- le **TGT** ou Ticket Granting Ticket : C'est le ticket qui nous est remis suite à notre authentification. Il sert à prouver qu'on s'est déjà authentifié
- Le **TGS** ou Ticket Granting Service : C'est le ticket qui nous permet d'accéder à tel ou tel service spécifique.

### 2. Token
C'est un objet numérique qui comporte des informations sur la personne en tant qu'utilisateur et ses droits :
- **L'analogie :** C'est exactement comme une **carte de chambre d'hôtel**.    
    - Elle ne contient pas ton nom ni ton adresse.        
    - Elle contient des données (numéro de chambre, date d'expiration).        
    - Le lecteur de la porte n'a pas besoin d'appeler la réception : il lit la carte, vérifie qu'elle est valide et non expirée, et ouvre la porte.

**Le format ROI : Le JWT (JSON Web Token)** 
1. **Header :** L'algorithme utilisé.    
2. **Payload :** Les données (ex: `"user": "eric"`, `"role": "admin"`).    
3. **Signature :** La preuve que le token n'a pas été modifié


___

### 3. Le SAML (Security Assertion Markup Language)

Il est le protocol le plus utilisé en entreprise. C'est lui qui permet le **Single Sign On**.
Dans le flux SAML, trois entités interviennent :
- Le **Principale** : l'utilisateur
- L'**Identity Provident (IdP)** : la source de confiance, là où sont stockés les identités (Microsoft Entra ID, Okta, etc)
- Le **Service Provider SP** : L'application à laquelle l'utilisateur veut accéder

**Le flux de connexion**
Imaginons qu'un utilisateur **Bob** souhaite se connecter à l'application de gestion de projet de son entreprise, le flux se présente comme suit :
- **La requête** : L'utilisateur essaie d'accéder à l'application (le SP) mais cette dernière voit qu'il n'est pas connecté
- **La redirection** : le SP redirige le navigateur vers l'IdP avec un message crypté demandant la vérification de l'identité de Bob qui tente d'accéder au navigateur
- **L'authentification** : l'IdP demande à Bob de s'authentifier (identifiants, MFA, Certificat, etc)
- **La création de l'assertion** : Une fois authentifié, l'IdP génère un fichier **XML** appelé **Assertion SAML**
- **La signature** : l'IdP signe ce fichier avec sa clé privée
- **Le retour au bercail** : l'IdP renvoie le fichier au navigateur qui le transmet automatiquement au SP
- **La vérification** : le SP vérifie la signature de l'Assertion XML avec la clé publique de l'IdP, si elle est valide, il laisse Bob entrer



