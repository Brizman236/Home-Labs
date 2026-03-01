
## Contexte & Objectifs

Dans un environnement informatique moderne, la sécurité des communications entre les systèmes constittue un enjeu fondamental. Les échanges entre serveurs et entre serveurs et clients doivent garantir la **confidentialité**, l'**intégrité** et l'**authenticité** des données.

Pour répondre à ces exigences, les organisations mettent en place des **infrastructures à clés publique** (ou **PKI** pour Public Key Infrastructure) permettant la gestion, l'émission et la validation des certificats numériques.

Une PKI interne permet notament :
- de vérifier l'authencité des serveurs : avec les certificats émis par une autorité de confiance, l'on peut savoir si un serveur est réellement celui qu'il prétend être
- d'assurer la confidentialité : grâce aux certificats, on peut créer une session TLS
- de vérifier l'intégrité avec les signatures numériques.

Sans PKI :
- Il n'y a pas d'identité fiable
- Une confidentialité peut-être assurée mais sans authentification, ce qui est vulnérable au Man In The Midde
 ___

Ce lab a pour objectif de déployer une infrastructure PKI dans un environnement contôlé. 
L'architecture mise en place comprendra une **Autorité de certification racine (Root CA)**, **une autorité intermédiare**, **un serveur DNS**, un **client Windows** et un **serveur WEB**.

Il vise à comprendre les mécanismes fondamentaux de la confiance numérique, le fonctionnement des certificats X.509, ainsi que l'importance de la séparation des rôles entre autorité racine et intermédiaire

___

## Topologie

![ChatGPT Image Feb 28, 2026, 07_49_39 AM](../Images/ChatGPT%20Image%20Feb%2028,%202026,%2007_49_39%20AM.png)


___


## Configuration réseau - Plan d'adressage IP

| **Machines**           | IP             | Hostname | FQDN            |
| ---------------------- | -------------- | -------- | --------------- |
| RootCA Intermediate CA | 192.168.122.20 | ca1      | ca1.cyber.local |
| DNS Server             | 192.168.122.10 | dns      | dns.cyber.local |
| Web Server             | 192.168.122.30 | web      | www.cyber.local |


___

##  Implémentation de l'architecture

> Le serveur DNS a déjà été mis en place, veuillez vous referez à ce lien 

___
### 1. Création du Root CA et de l'Intermediate CA

Le **Root CA** est la **source ultime** de confiance de toute la PKI, il établit la racine de la **chaîne de confiance**. 
Il génère sa propre clé privée, emet un certification auto-signé et ne signe uniquement les certificats des autorités intermédiaires.
En production, ce dernier est mis **hors-ligne** car si sa clé privée est compromise, toute la PKI devient non fiable et doit-être reconstruite. Cependant dans notre Lab nous la garderons en ligne avec le Intermediate CA.

L'**Intermediate CA** est l'autorité opérationnelle:
- Il génère sa clé privée
- Reçoit un certificat signé par le **Root CA**
- Signe les certificats serveurs
- Gère les révocations

Le rôle stratégique de l'intermediate CA est de limiter l'impact d'une compromission. Si sa clé privée est compromise, on la révoque et l'on crée une nouvelle autorité intermédiaire.

#### Création du Root CA

```sh
# Génération de la clé du RootCA avec le passphrase : JG/IpvS3gxqzKg5J
openssl genrsa -aes256 -out ~/pki/root/private/root.key 4096

# Génération du certificat du RootCA valide pour 1 an
openssl req -x509 -new -key ~/pki/root/private/root.key -sha256 -days 7300 -out ~/pki/root/certs/root.crt
```

![Pasted image 20260228092648](../Images/Pasted%20image%2020260228092648.png)

___

#### Création de l'intermediate CA

```sh
# Génération de la clé privée avec passphrase : +ptIxeoDsc+kVzer
openssl genrsa -aes256 -out ~/pki/intermediate/private/intermediate.key 4096
```

Nous allons créer un fichier de configuration qui servira à générer le CSR :
```sh
nano ~/pki/intermediate/certs/intermediate.cnf
```

```conf
[ req ]
default_bits        = 4096
prompt              = no
default_md          = sha256
distinguished_name  = dn
req_extensions      = req_ext

[ dn ]
C  = SN
ST = Senegal
L  = Dakar
O  = Cyber Lab
OU = Self
CN = Lab Intermediate CA

[ req_ext ]
basicConstraints = CA:true, pathlen:0
keyUsage = keyCertSign
subjectKeyIdentifier = hash
```

- `basicConstraints = CA:true, pathlen:0` pour spécifier que ce sera une autorité de certificat. `pathlen:0` permet de limiter la surface d'attaque en empêchant l'intermediate de signer d'autres SubCA
- `keyUsage = keyCertSign` spécifie que le rôle du certificat qui doit être ici de signer d'autres certificat
- `subjectKeyIdentifier = hash` génère une empreinte de la clé publique

Nous allons créer un fichier pour les extensions, car le CA peut ne pas accepter les extensions mis dans la requête.

```sh
nano ~/pki/intermediate/certs/intermediate_ext.cnf
```

```
[ req_ext ]

basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
```

Suite à cela, générons le CSR, puis demandons le certificat en l'utilisant et en spécifiant le fichier des extensions
```sh
# Création du csr
openssl req -new -key ~/pki/intermediate/private/intermediate.key -out ~/pki/intermediate/csr/intermediate.csr -config ~/pki/intermediate/csr/intermediate.cnf

# Création et signature du certificat par le Root CA
openssl x509 -req \
-in ~/pki/intermediate/csr/intermediate.csr \
-CA ~/pki/root/certs/root.crt \
-CAkey ~/pki/root/private/root.key \
-extfile ~/pki/intermediate/certs/intermediate_ext.cnf \
-extensions req_ext \
-out ~/pki/intermediate/certs/intermediate.crt \
-days 3650 -sha256 # 10 ans
```


![Pasted image 20260301012604](../Images/Pasted%20image%2020260301012604.png)
![Pasted image 20260301012621](../Images/Pasted%20image%2020260301012621.png)


___

### **2. Déployement du serveur WEB**

#### **Création de la clé privée et demande du certificat**

Depuis le serveur, nous allons générer sa clé privée, ensuite demander un certificat signé par l'**Intermediate CA**.

```sh
# La clé privée  
openssl genrsa -out /etc/ssl/lab/private/webserver.key 4096

# La protéger
sudo chmod 600 /etc/ssl/lab/private/webserver.key
# Le fichier de configuration du CSR
nano webserver.cnf
```

```cnf
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
CN = www.cyber.lab

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = www.cyber.lab
```

Le fichier `.cnf` est essentiel car il permet de définir le **SAN** (subjectAltName) obligatoire pour du **HTTPS** moderne., il précise le domaine sur lequel le certificat est valide ici `www.cyber.lab`
Nous allons maintenant générer la requête du certificat le **CSR** :

```sh
openssl req -new \
-key /etc/ssl/lab/private/webserver.key \
-out webserver.csr \
-config webserver.cnf
```


Nous allons copier le **CSR** sur le **CA** vie `scp` :

```sh
scp webserver.csr ca1@ca1.cyber.lab:~/
```

![Pasted image 20260228105715](../Images/Pasted%20image%2020260228105715.png)

Comme précédement pour l'**intermediate CA**, nous allons créer un fichier de configuration pour les extensions de certificat du serveur :

```sh
nano wbserveur_ext.cnf
```

```conf
[ req_ext ]  
  
basicConstraints = CA:FALSE  
keyUsage = critical, digitalSignature, keyEncipherment  
extendedKeyUsage = serverAuth
subjectAltName = DNS:www.cyber.lab
```

- `basicConstraints = CA:FALSE` le serveur n'est pas une **CA**
- `keyUsage = critical, digitalSignature, keyEncipherment`  : `digitalSignature` pour l'authentification du serveur et signature du TLS, `keyEncipherment` pour l'échange sécurisé des clés de chiffrement. `critical` force la vérification du rôle du certificat avant son utilisation.
- `extendedKeyUsage = serverAuth` spécifie que le certicat est utilisé pour du TLS


```sh
openssl x509 -req -in /home/ca1/webserver.csr -CA pki/intermediate/certs/intermediate.crt -CAkey pki/intermediate/private/intermediate.key -extfile wbserveur_ext.cnf -extensions req_ext -out webserver.crt -days 730 -sha256
```

![Pasted image 20260301013911](../Images/Pasted%20image%2020260301013911.png)
![Pasted image 20260301013925](../Images/Pasted%20image%2020260301013925.png)

Après la création du certificat signé du serveur web, nous allons le copier du ce dernier avec la chaîne de confiance. 
La chaîne ce confiance sera constitué des certificat de l'Intermediate et du serveur web.

```sh
cat  webserver.crt pki/intermediate/certs/intermediate.crt > ca-chain.crt
scp ca-chain.crt web@www.cyber.lab:~/
scp webserver.crt web@www.cyber.lab:~/
```

Nous allons maintenant revenir sur le serveur web pour copier le certificat et la chaine dans le dossier `/etc/ssl/lab/certs` :

```sh
cp ca-chain.crt /etc/ssl/lab/certs
cp webserver.crt /etc/ssl/lab/certs
```

___

#### Déployement du serveur WEB

Le serveur WEB que nous utiliserons sera sous `apache`

```sh
# Mise à jour du dépôt
apt update

# Installation d'Apache
apt install apache2

# Activation du mode SSL
a2enmod ssl
systemctl restart apache2
```

Nous allons créer un VirtualHost pour le HTTPS :

```sh
nano /etc/apache2/sites-available/lab.conf
```

```conf
<VirtualHost *:443>

    ServerName www.cyber.lab

    SSLEngine on

    SSLCertificateFile /etc/ssl/lab/certs/webserver.crt
    SSLCertificateKeyFile /etc/ssl/lab/private/webserver.key
    SSLCertificateChainFile /etc/ssl/lab/certs/ca-chain.crt

    DocumentRoot /var/www/html

</VirtualHost>
```

**Explication** :
- `*:443` → écoute sur le port HTTPS
- `ServerName` → doit correspondre au certificat (SAN)
- `SSLEngine on` → active TLS
- `SSLCertificateFile` → certificat serveur
- `SSLCertificateKeyFile` → clé privée
- `SSLCertificateChainFile` → chaîne intermédiaire

Puis nous allons activer le site :

```sh
a2ensite lab.conf
systemctl reload apache2
```

___

### Test de la configuration sur le Windows

Dans cette partie nous allons accéder au serveur web via HTTPS depuis un Client Windows 10. Avant de commencer nous allons d'abord recupérer le certificat du **Root CA**. Pour cela, dans le cadre de ce lab nous allons démarrer un serveur web via le module Python `http.server` au port `8000` du `CA` :

```
root@ca1:~# python3 -m http.server
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

Puis y accéder via le navigateur du client et télécharger le certificat :

![Pasted image 20260301015944](../Images/Pasted%20image%2020260301015944.png)

Accédons au site : `ww.cyber.lab`

![[Pasted image 20260301021936.png]]

Nous avions un avertissement nous disant que la **Connexion n'est pas privée**. Cela est du au fait que le Client ne fait pas confiance au certificat et à la chaîne de certificat fournis par le serveur web. 

Importons le certificat du **Root CA** dans le navigateur en allant dans **Paramètres > Confidentialité et Sécurié > Sécurité > Gérer les certificats > Installé par vous** :

![[Pasted image 20260301022246.png]]

Revenons sur la page du serveur web et actualisons-la :

![[Pasted image 20260301022328.png]]

![[Pasted image 20260301022354.png]]

Nous pouvons voir que la chaîne de confiance est vérifier et que nous n'avons plus d'avertissement.

___

## **Conclusion**

Ce laboratoire a permis de mettre en place une **infrastructure à clés publiques (PKI) complète** en environnement contrôlé, composée d’une **Autorité de Certification Racine (Root CA)**, d’une **Autorité de Certification Intermédiaire (Intermediate CA)**, d’un **serveur DNS**, d’un **serveur Web** et d’un **client Windows**.

L’architecture implémentée respecte les **bonnes pratiques de sécurité**, notamment :

- 🔐 La séparation des rôles entre la Root CA et l’Intermediate CA
    
- 🔒 L’utilisation d’une chaîne de confiance hiérarchique
    
- 🧾 La génération et la signature de certificats X.509 conformes aux standards
    
- 🌐 L’utilisation obligatoire du **Subject Alternative Name (SAN)** pour la validation moderne des noms de domaine
    
- 🛡 La configuration correcte des extensions critiques (Basic Constraints, Key Usage, Extended Key Usage)
    

La mise en place d’un certificat serveur signé par l’Intermediate CA, puis l’importation du certificat racine dans le magasin de confiance du client, a permis de valider le fonctionnement de la **chaîne de confiance complète**. L’accès au serveur Web en HTTPS sans erreur de certificat démontre que :

- L’authenticité du serveur est vérifiée
    
- La connexion est chiffrée via TLS
    
- L’intégrité des communications est garantie
    
- Le modèle de confiance PKI fonctionne correctement
    

Ce lab met également en évidence un principe fondamental de la cybersécurité :

> **La sécurité ne repose pas uniquement sur le chiffrement, mais sur la gestion correcte de l’identité et de la confiance.**

Enfin, cette implémentation permet de comprendre en profondeur :

- Le fonctionnement des certificats X.509
    
- Le rôle des extensions dans la définition des usages
    
- L’importance de la chaîne de certification
    
- Le mécanisme de validation côté client
    
- La séparation stratégique entre Root CA (hors ligne en production) et Intermediate CA
    

Ce travail constitue une base solide pour évoluer vers des architectures plus avancées telles que :

- Gestion des révocations (CRL / OCSP)
    
- Déploiement en environnement entreprise
    
- PKI à grande échelle
    
- Intégration avec des services d’authentification
    
- Sécurisation des communications internes
    

En conclusion, ce laboratoire démontre une compréhension pratique et technique des mécanismes de confiance numérique et constitue une étape essentielle dans la maîtrise des infrastructures de sécurité modernes.