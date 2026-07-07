## Module 3 : Microsoft Entra ID (Ton premier pas dans le Cloud)

### La problèmatique

Traditionnellement en entrprise, l'on dispose d'un serveur AD local dans notre réseau local et des applications, soit web ou autre. Pour pouvoir s'authentifier, l'ordinateur sur lequel l'utilisateur s'authentifie doit pouvoir **voir** le DC, l'IdP.

Imaginons maitenant que notre entreprise souhaite étendre son business et embauche des employés à l'extérieur de l'entreprise.

Prenons une entreprise dans la production et la distribution dont une grande partie des employés sont dans les points de distributions et utilisant leur téléphone et la 4G. Ils sont censé accéder aux applications de l'entreprise, s'y authentifier, et accéder aux ressources de l'entreprise. 

Dans ce cas de figure, les utilisateurs utilisant la 4G et de ce fait n'étant pas dans le réseau local ne "voient" pas le DC, ni l'IdP du réseau local et donc ne peuvent pas les contacter, ne peuvent pas s'authentifier.

Comment faire ? Comment faire déjà pour qu'il puisse s'authentifier ? Puis pour qu'ils puissent accéder aux ressources de l'entreprise ?

C'est la qu'intervient l'identité hybride avec la solution **Cloud** **Microsoft Entra ID**.

____
**Entra ID** est un énorme annuaire dans lequel les identités du serveur AD local y sont synchronisées via un agent installé sur ce serveur.

___

#### Vers le Zero trust

Le **Zero trust** est le fait d'ajouter une couche conditionnelle et contextuelle à la distribution des accès. Par exemple un RH authentifié correctement mais qui se connecte à 2h du matin un samedi soir depuis une IP venant d'un autre pays, ou bien un utilisateur qui s'authentifie correctement mais dont l'ordinateur est plein de logiciel crackés.

Dans Entra ID, il y a deux types de risque :
- **Risque Utlisateur** : Qqn a volé le mot de passe d'un user. Solution MFA
- **Risque Machine** : PC infecté, user sain mais environnement sale

En **Zero Trust**, l'identité ne fait pas le seul object de vérification, l'on contrôle aussi tout ce qui l'entoure, ses attributs. Et chque élément d'information est un signal.

L'on a quatre catégories :
- **Qui ?** (L'utilisateur et son rôle : est-ce un étudiant ? Un prof ? Un admin ?)
- **D'où ?** (Le signal de localisation : IP de l'université, pays inhabituel, réseau Wi-Fi public ?)    
- **Avec quoi ?** (Le signal du périphérique : PC géré par l'UCAD, smartphone personnel, état de santé de l'antivirus ?)    
- **Pour quoi faire ?** (L'application : lire ses mails ou accéder à la base de données des diplômes ?)

___

## La fédération d'identité

C'est le pilier qui permet de séparer la **vérification** l'identité et l'**utilisation** de celle-ci. Par exemple quand une application **Zoom** ou **Office 365** décide de faire aveuglément confiance au serveur AD. On appelle cela une **Relation de Confiance**. Techniquement elle est basée sur la cryptographie asymétrique :
- l'IdP possède une clé privée
- et le SP la clé publique dérivée

___
### Continuous Access Evaluation

Dans la fédération d'identité, la méthode la plus utilisée pour transporter l'identité est l'utilsation d'un Token signé avec la clé privée de l'IdP. Ce Token permet à l'utilisateur d'avoir accès à une application (un SP) sans utiliser son mot de passe ou quoi que ce soit d'autre. IL faut aussi noter que ce Token a une durée de vie Limitée.

Dans le cas où un évènement critique se produit (changement de mdp, désactivation du compte, etc), les systèmes ne vont pas attendre que le jeton soit expiré pour revérifier l'identité de l'utilisateur. L'IdP et le SP garde toujours un canal de communication ouvert, lors d'un évènement critique, l'IdP envoie une notification à tous les SPs en temps réels. Ces derniers, après avoir reçu la notification invalident immédiatement la session de ou des utilisateurs concernés. C'est ça le **Continuous Access Evaluation**

Le framework open-source utilisé pour cette communication est le **Shared Signals Framework**, il permet aux plateformes d'échanger des signaux de sécurité.








