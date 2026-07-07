## Prérequis

|**Caractéristique**|**Unité d'Organisation (OU)**|**Groupe**|
|---|---|---|
|**Objectif**|Organiser et déléguer l'administration.|Accorder des droits et accès.|
|**Politiques**|On y lie des **GPO**.|On y lie des **Permissions (ACL)**.|
|**Appartenance**|Un objet est dans **une seule** OU.|Un objet peut être dans **plusieurs** groupes.|
|**Visibilité**|Invisible pour l'utilisateur final.|Parfois visible (listes de diffusion, etc.).|

___
## Le cycle de vie de l'identité

Les identités suivent un processus bien défini, le **JML** :
- **Joiner (L'arrivée) :** Création du compte, attribution des droits de base (e-mail, badge).    
- **Mover (Le mouvement) :** Tu passes du marketing à la cybersécurité. Tes anciens droits doivent être révoqués, les nouveaux ajoutés. C'est là que le bât blesse souvent (on garde trop de droits).    
- **Leaver (Le départ) :** Suppression ou désactivation immédiate.

Il existe un certain parallélisme entre le leaver et la CRL en PKI. La **révocation**. En IAM le processus est industrialisé comme suit:
- **L'automatisation du Leaver** : Quand un RH marque un employé comme **Parti**, le système IAM doit révoquer automatiquement les accès
- **La revue d'acces** : Chaque 6 mois, les managers recoivent une liste "*Amadou  toujours accès à ce serveur ? est-ce normal ?*", s'il n'y a pas validation l'accès est coupé.

#### Mise en pratique : RBAC

Pour éviter de gérer 1000 utilisateurs un par un, on utilise des rôles, ça fonctionne comme suit :
- On a un rôle "Analyste SOC" qui est lié à plusieurs accès
- Eric est un nouveau employé analyste soc. Au lieu de lui attribuer les accès manuellement un à un, on l'ajoute au groupe "Analyste SOC" et hérite directement des accès
- Il change de département, on lui retire le rôle et il perd directement ses anciens accès

___

### La séparation des droit - Segregation of Duties (SoD)

Un concept de **gouvernance**. C'est simple, aucune personne seule ne doit avoir assez de droits, d'accès pour commettre une fraude sans être détecté.

#### Exemple de mise en pratique

L'on applique le SoD via des combinaisons interdites de groupes :
-  **Le Cas** : Un administrateur système ne doit pas pouvoir valider ses propres modifications de salaires
- **La mise en pratique** :
	1. Le **Groupe A** : 'Gestionnaire de Paie', c'est eux qui s'occupe de la modification des chiffres
	2. Le **Groupe B** : 'Validateurs de Paie' ils valident les modifications et procèdent aux virements
- La **SoD** : le système IAM interdit technique qu'un utilisateur fasse partie des deux groupes à la fois. Si un utilisateur de l'un tente d'être dans l'autre, soit ses accès précédents sont révoqueé, soit une alerte est soulevée, soit il est bloqué

C'est ce qu'on appelle une **Matrice de Toxicité**. On liste les droits qui, une fois cumulés, deviennent "toxiques".

