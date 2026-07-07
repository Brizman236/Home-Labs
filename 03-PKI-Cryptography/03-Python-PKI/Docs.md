Parfait ! On va se concentrer sur un **Lab EJBCA pur**, structuré, opérationnel, qui te servira de base pour tout ce qui est PKI industrielle.

Voici une proposition détaillée :

---

## **Lab 4 : PKI Réaliste avec EJBCA**

### **Objectif**

Mettre en place une PKI complète utilisant **EJBCA**, avec :

- Autorité de certification racine (Root CA)
    
- Autorité de certification subordonnée (SubCA)
    
- Gestion des certificats utilisateurs et serveurs
    
- Révocation via CRL et OCSP
    
- Préparation pour intégration future de **Transparency Authorities / logs immuables**
    

---

### **1️⃣ Architecture du Lab**

```
+-----------------------+
| Root CA (EJBCA)       |
| - Offline possible     |
+-----------------------+
          |
          v
+-----------------------+
| SubCA (EJBCA)         |
| - Online / Signing    |
| - Certs: Diplômes     |
+-----------------------+
          |
          v
+-----------------------+
| Clients / Applications|
| - Vérif diplômes      |
| - Demande certificat  |
+-----------------------+
```

**Optionnel** : un **HSM SoftHSM2** pour stocker la clé privée du SubCA et simuler production.

---

### **2️⃣ Objectifs techniques**

1. Créer la **Root CA** et exporter son certificat.
    
2. Créer une **SubCA** pour signer les certificats applicatifs (ex. diplômes).
    
3. Déployer **SoftHSM2** pour stocker les clés privées de la SubCA.
    
4. Configurer **CRL et OCSP** pour gérer les révocations.
    
5. Générer des certificats pour les “clients” (applications, serveurs).
    
6. Préparer un **script de génération automatique de certificats PDF signés**.
    

---

### **3️⃣ Composants à installer**

- **EJBCA 8.x** (latest stable)
    
- **Java JDK 17+**
    
- **WildFly / Tomcat** pour héberger EJBCA
    
- **PostgreSQL / MySQL** pour la DB EJBCA
    
- **SoftHSM2** pour HSM simulé
    

---

### **4️⃣ Exemples de fonctionnalités**

- Création de certificats utilisateur avec :
    
    - CN = nom étudiant
        
    - OU = diplôme
        
    - Extensions personnalisées pour **validité et timestamp**
        
- Révocation automatique si besoin
    
- Export en **PKCS#12** pour intégration avec PDF signing (PyHanko / OpenPDF)
    

---

### **5️⃣ Bonus**

- Préparer un **connecteur REST API** pour générer des certificats dynamiquement → base pour un **Agent Automation** futur.
    
- Possibilité d’ajouter **audit logs** pour chaque signature.
    

---

💡 Avec ce Lab, tu auras un **environnement PKI réaliste**, sur lequel tu pourras :

- Tester l’émission de certificats
    
- Tester les révocations et OCSP
    
- Préparer l’intégration future de Transparency Authorities
    

---

Si tu veux, je peux te **fournir le Lab étape par étape avec commandes exactes**, depuis l’installation de EJBCA jusqu’à la génération d’un certificat utilisateur prêt à signer un document PDF.

Veux‑tu que je fasse ça ?