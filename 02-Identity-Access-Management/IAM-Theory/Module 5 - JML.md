
## JML

C'est le concept qui définit les trois étapes du cycle de vie d'une identité d'un utilisateur dans l'IAM :
- Le **Joiner** : La création automatique des comptes et attributions des droits de base dès que la personne est recrutée ou inscrite
- Le **Mover** : La mise à jour des droits au changement 
- Le  **Leaver** : Désactivation immédiate et automatique de tous les accès de l'utilisateur lorsque ce dernier quitte l'entreprise

Avec le Mover, l'on atttribut de nouveaux droits à l'utilisateur mais sans nettoyer ou retirer les anciens, ce qui est un problème.  Pour régler cela, il y a un process nommé **Access Review** consistant à faire une campagne périodique pour attester si oui ou non tel utilisateur à toujours besoin de tel droit?
- **Décision :** Le manager doit cliquer sur "Maintenir" ou "Révoquer".    
- **Audit :** C'est une preuve juridique indispensable pour les certifications de sécurité (comme l'ISO 27001). Si un accès n'est pas re-validé, le système le supprime automatiquement.

___

### Le Provisionning et le Deprovisionning

- **Le Provisionning** : L'action d'aller créer automatiquement les différents comptes de l'utilisateur (LDAP, Google Workspace, apps)
- Le **Deprovisionning** : L'inverse


___

### La source de vérité

L'on n'invente pas une identité en IAM, elle doit provenir d'un système maître : **Le logiciel RH**
Lorsque les RH y enregistre un nouvel employé, le système IAM détecte le changement et lance le **Provisionning**

___

#



