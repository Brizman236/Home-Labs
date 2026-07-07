
### RBAC - Role-Based Access Control

C'est l'attribution des droits par groupe. 
- L'on crée un groupe par ex **RH**. 
- Le Rôle : l'ensemble des permissions par ex **Lecteur_CV**
- Tous les utilisateurs qui seront ajoutés dans ce groupe hériterons automatiquement du rôle **Lecteur_CV**
- Si un RH démissionne, on lui retire le rôle et il perdra tous ses droits

> NB : Il faut savoir faire la différence entre Groupe dans l'annuaire et un Rôle dans une application

Ce modèle d'attribution des accès conduit à un problème lorsqu'il y a une certaine disparité entre les utilisateurs d'un même groupe. 
- un étudiant qui ne s'est inscrit que cette année,
- Uniquement pendant les heures de pauses
- Uniquement les connexions depuis le campus

Cela conduit à une explosion des rôles. Pour résoudre cela, un autre modèle est utilisé : le **ABAC** pour **Attribute-Based Access Control**.

___
### ABAC : Attribute-Based Access Control

Au lieu de d'appliquer les règles si l'user appartient à tel ou tel groupe, on crée des **politiques** qui croisent des informations pour prendre une décision.

L'**ABAC** se base sur 4 types d'attributs :
- **Attributs du Sujet** : Son grade, son département, son âge, son statut d'inscription (ex: `En_Règle = True`).
- **Attributs de la ressource** : Le type de document (Diplôme, Bulletin de notes), son niveau de confidentialité (Public, Secret).
- **Attributs de l'Action** : Lire, Écrire, Supprimer, mais surtout **Signer**.
- **Attributs de l'environnement (le contexte)** : l'heure, le jour, l'IP, l'etat du PC

**Avantage :** Une seule règle peut gérer 30 000 personnes. _Exemple :_ "Autoriser l'accès à la bibliothèque si `Sujet.Rôle == Etudiant` ET `Environnement.Heure < 18h00` ET `Sujet.Inscrit == True`.

L'annuaire LDAP n'est plus la seule source de condition. Un composant logiciel est utilisé pour recevoir la requête d'accès et "calculer" la réponse en temps réel : le **Policy Decision Point**. C'est ce dernier qui va collecter les informations :
- Il demande à l'annuaire : _"Est-ce que cet étudiant a payé ses frais ?"_    
- Il demande au système réseau : _"Est-il sur le Wi-Fi de l'université ?"_    
- Il demande au système de sécurité : _"Son PC est-il infecté ?"_

S'il y a un **match** partout il accepte sinon il refuse.

___
### Le PBAC (Policy-Based Access Control)

C'est le terme souvent utilisé en entreprise pour décrire la mise en pratique de l'ABAC. C'est l'idée que l'accès n'est plus une "permission" gravée dans le marbre, mais le résultat d'une **politique de sécurité** qui peut changer en un clic pour tout le monde.
- _Scénario de crise :_ Une cyberattaque frappe l'université    
- **En RBAC :** Il faudrait retirer 30 000 personnes des groupes. L'enfer.    
- **En PBAC :** Tu modifies une seule ligne dans ton moteur de politique : `"Autoriser si Localisation == Campus_Physique"`. Instantanément, tous les accès externes (VPN/Hôtel) sont coupés pour tout le monde.

___

### Le PAM

C'est une branche de l'IAM qui se concentre sur les **comptes à aux risques** (Administrateurs, root, Super Admin, Compte de Service). AU lieu de laisser un Admin utiliser son compte pour tout faire, c'est à dire qu'il peut disposer de tous les accès du moment où il est connecté, on sépare ses accès, on les place derrière une passerelle. De telle sorte qu'il ne peut les avoir que quand il en a besoin pour une durée bien déterminée.

Le PAM permet de :

1. **Isoler les secrets :** L'admin ne connaît même pas le mot de passe "root", c'est le système PAM qui l'injecte pour lui.    
2. **Enregistrer les sessions :** Tout ce que fait l'admin est filmé ou logué (utile pour le forensic).    
3. **Contrôler le temps :** C'est là qu'intervient le JIT.

___

### Just-In-Time Access

Le principe est de donner le ou les droits qu'au moment de l'action. Le flux :
- l'admin demande l'accès pour une tâche spécifique
- Le workflow d'approbation est déclenché
- Le droit est attribué pour la durée necéssaire (ex 2h)
- Les droits sont retirés au bout de ce délai par le système PAM

___

## Concept : Break-glass (Le compte de secours)

Puisque tout est verrouillé par du JIT et des MFA, que se passe-t-il si le système d'authentification tombe en panne (ex: le serveur Keycloak est HS) ? C'est le concept du compte "Break-glass" (Brise-glace) :
- C'est un compte "root" d'urgence, avec un mot de passe extrêmement complexe coupé en deux et stocké dans deux coffres-forts physiques différents.    
- On ne l'utilise **jamais**, sauf en cas de catastrophe totale.    
- Son utilisation déclenche des alertes maximales sur tous les téléphones des responsables sécurité.




