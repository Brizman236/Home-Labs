```
PHASE 1 — Infrastructure
   ├── 1.1  Créer/renommer les VMs
   ├── 1.2  Configurer hostnames + /etc/hosts
   ├── 1.3  Configurer le DNS
   └── 1.4  Installer les outils (OpenSSL, SoftHSM2, Step-CA, PyHanko)

PHASE 2 — PKI MESRI (Root CA — OpenSSL + SoftHSM2)
   ├── 2.1  Initialiser SoftHSM2 sur mesri-ca
   ├── 2.2  Générer la clé Root CA dans SoftHSM2 via PKCS#11
   ├── 2.3  Créer le certificat Root CA avec OpenSSL
   └── 2.4  Générer la CRL initiale

PHASE 3 — PKI UCAD (Intermediate CA — Step-CA + SoftHSM2)
   ├── 3.1  Initialiser SoftHSM2 sur ucad-ca
   ├── 3.2  Installer et initialiser Step-CA
   ├── 3.3  Générer le CSR Intermediate CA
   ├── 3.4  Faire signer par MESRI
   └── 3.5  Configurer Step-CA avec le certificat signé

PHASE 4 — Certificat Recteur (Dr. Diallo)
   ├── 4.1  Initialiser SoftHSM2 sur recteur
   ├── 4.2  Générer clé privée dans SoftHSM2
   ├── 4.3  Émettre certificat de signature via Step-CA
   └── 4.4  Exporter en .p12

PHASE 5 — PKI Server (CRL + OCSP)
   ├── 5.1  Initialiser SoftHSM2 sur pki-server
   ├── 5.2  Configurer Apache + VirtualHost pki.cyber.lab
   ├── 5.3  Déployer OCSP Responder
   └── 5.4  Publier les CRLs

PHASE 6 — Signature PDF
   ├── 6.1  Installer PyHanko sur recteur
   ├── 6.2  Configurer PyHanko avec SoftHSM2
   ├── 6.3  Créer le diplôme PDF
   └── 6.4  Signer avec PAdES-LTV

PHASE 7 — Vérification Adobe
   ├── 7.1  Importer Root CA dans Adobe Reader
   ├── 7.2  Ouvrir le PDF signé
   └── 7.3  Valider la chaîne de confiance

PHASE 8 — Documentation
   └── 8.1  Rédiger le lab complet

PHASE 7 — Documentation
   └── 7.1  Rédiger le lab
```

## PHASE 5 - PKI Server

Le `pki-server` est le serveur qui rend accessible tous les éléments nécessaires à la vérification de la validité des certificats en publiant des CRLs et en hébergeant des OCSP Responders.

L'on va y déployer un serveur web Apache, puis nous allons configurer les endpoints comme suit :
- `/ocsp/root` et `/ocsp/intermediate` : les OCSP responders
- `/crl` : les CRLs
Avec `step-ca` il est possible de démarrer un mini serveur hébergeant la CRL et accessible via HTTP. Nous automatiserons le téléchargement du CRL depuis le `pki-server` toutes les 1 heures.

Nous allons :
- Initialiser le token `pki-ocsp` et générer la paire de clé
- Générer le CSR des OSCP Responders 
- Emettre les certificats des OSCP Responders
- Configurer le serveur web 
- Emettre des CRLs
- Tester la révocation

### PHASE 5.1  : Initialisation du Token et Génération de la paire de clé

Initialisation du token :
```sh
softhsm2-util --init-token --label "pki-ocsp" --pin 1234 --so-pin 5678 --slot 0
```

Génération de la paire de clé :
```sh
pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so --login --label "pki-ocsp" --keypairgen --key-type rsa:4096 --pin 1234
```

Récuperation de leur URL :
```sh
 p11tool --list-all --login "pkcs11:token=pki-ocsp"
```

```text
Object 0:
	URL: pkcs11:model=SoftHSM%20v2;manufacturer=SoftHSM%20project;serial=c5319d1b747b6a64;token=pki-ocsp;object=pki-ocsp;type=public
	Type: Public key (RSA-4096)
	Label: pki-ocsp
	Flags: CKA_WRAP/UNWRAP; 
	ID: 

Object 1:
	URL: pkcs11:model=SoftHSM%20v2;manufacturer=SoftHSM%20project;serial=c5319d1b747b6a64;token=pki-ocsp;object=pki-ocsp;type=private
	Type: Private key (RSA-4096)
	Label: pki-ocsp
	Flags: CKA_WRAP/UNWRAP; CKA_PRIVATE; CKA_NEVER_EXTRACTABLE; CKA_SENSITIVE; 
	ID: 
```


### PHASE 5.3 : Géneration des CSR

```sh

# Pour le OCSP du Root CA
openssl req -new \
  -engine pkcs11 \
  -keyform engine \
  -key "pkcs11:model=SoftHSM%20v2;manufacturer=SoftHSM%20project;serial=c5319d1b747b6a64;token=pki-ocsp;object=pki-ocsp;type=public?pin-value=1234" \
  -out ~/ocsp-mesri.csr \
  -subj "/C=SN/ST=Senegal/O=MESRI/CN=OCSP Responder MESRI"
scp ~/ocsp-mesri.csr root@rootca1.cyber.lab

# Pour le OCSP du SubCA
openssl req -new \
  -engine pkcs11 \
  -keyform engine \
  -key "pkcs11:model=SoftHSM%20v2;manufacturer=SoftHSM%20project;serial=c5319d1b747b6a64;token=pki-ocsp;object=pki-ocsp;type=public?pin-value=1234" \
  -out ~/ocsp-ucad.csr \
  -subj "/C=SN/ST=Senegal/O=UCAD/CN=OCSP Responder UCAD"
scp ~/ocsp-ucad.csr root@subcaca1.cyber.lab
# Copie sur 
scp recteur.csr root@192.168.122.40:~/
```


### PHASE 5.3 : Emission des certificats des OCSP Responders

```sh
# Sur le Root CA
openssl ca -config /root/pki/root/root.cnf \
  -extensions ocsp \
  -days 365 -notext -md sha256 \
  -engine pkcs11 \
  -keyform engine \
  -keyfile "pkcs11:token=mesri-root;object=mesri-root-key;type=private;pin-value=1234" \
  -in ~/ocsp-mesri.csr \
  -out ~/ocsp-mesri.crt

scp ocsp-mesri.crt  root@pki.cyber.lab:~/
```

Pour pouvoir émettre le certificat du OCSP Reponder du SubCA, il nous faut un template et un provisionner auquel sera rattaché le template.  Créons de ce fait le template du Responder dans `~/.step/templates/ocsp-template.json`:
```json
{
    "subject": {{ toJson .Subject }},
    "keyUsage": ["digitalSignature"],
    "extKeyUsage": ["ocspSigning"],
    "basicConstraints": {
        "isCA": false
    },
    "extensions": [
        {
            "id": "1.3.6.1.5.5.7.48.1.5",
            "critical": false,
            "value": ""
        }
    ]
}
```

> Lors d'une vérification, le client est amené à vérifier si le certificat du OCSP Responder n'a pas été lui même révoqué ce qui peut entraîner une boucle infinie de vérification.  C'est là que l'extension `id-pkix-ocsp-nocheck` avec l'OID `1.3.6.1.5.5.7.48.1.5` intervient, il spécifie au client de ne pas vérifier la révocation du certificat du OCSP Responder.

Rattachons le template au provisionner `admin@ucad.sn` et émettons le certificat du Responder:
```sh
step ca provisioner update admin@ucad.sn --x509-template .step/templates/ocsp-template.json
step ca sign ocsp-ucad.csr ocsp-ucad.crt
scp ocsp-ucad.crt root@pki.cyber.lab:~/
```

### PHASE 5.4 : Configuration du serveur WEB

Nous allons créer un VirtualHost qui hébergera nos endpoints :
```sh
# La structure de dossier
mkdir -p /var/www/revoke/crl
mkdir -p /var/www/revoke/ocsp/root
mkdir -p /var/www/revoke/ocsp/intermediate

# Configuration du virtualHost
nano /etc/apache2/sites-available/revoke.conf
```

```sh
<VirtualHost *:80>
    ServerName pki.cyber.lab
    DocumentRoot /var/www/revoke

    <Directory /var/www/revoke>
        Options Indexes
        AllowOverride None
        Require all granted
    </Directory>

    # Reverse Proxy OCSP Root
    ProxyPass /ocsp/root http://pki.cyber.lab:2560
    ProxyPassReverse /ocsp/root http://pki.cyber.lab:2560
    
    # OCSP Intermediate
    ProxyPass /ocsp/intermediate http://pki.cyber.lab:2561
    ProxyPassReverse /ocsp/intermediate http://pki.cyber.lab:2561
</VirtualHost>
```

Nous allons maintenant activer les modules apache nécessaires et activer le site :
```sh
# Activation des modules nécessaires
a2enmod proxy proxy_http
# Activation du Site
a2ensite crl.conf

systemctl reload apache2
```


### PHASE 5.5 : Emission des CRLs

Sur le Root CA nous allons utilisé OpenSSL pour générer et signer le CRL puis le copier sur le `pki-server` :

```sh
openssl ca -config /root/pki/root/root.cnf \
  -gencrl \
  -engine pkcs11 \
  -keyform engine \
  -keyfile "pkcs11:token=mesri-root;object=mesri-root-key;type=private;pin-value=1234" \
  -out /root/pki/root/crl/root.crl
  
scp /root/pki/root/crl/root.crl root@pki.cyber.lab:/var/www/revoke/crl/
```

En ce qui concerne la CRL du SubCA, nous allons d'abord démarrer le serveur CRL intégré en ajoutant ceci à `ca.json` :

```json
"insecureAddress": ":9001",
"crl": {
  "enabled": true,
  "idpURL": "http://subca1.cyber.lab/1.0/crl"
},
```

Le serveur sera accessible sur le port 9001 via HTTP après redémarrage du `step-ca`.
Nous allons ensuite téléchargé la CRL sur le pki-server dans `/var/www/revoke/crl` :

```sh
curl -o /var/www/revoke/crl/intermediate.crl http://subca1.cyber.lab:9001/1.0/crl
```

Les certificats pouvant être révoqués à tout moment par le SubCA, nous allons configurer une tâche dans le `cron` pour pouvoir télécharger le CRL tout les 1h :

```sh
crontab -e

# Puis ajouter la ligne :
curl -o /var/www/revoke/crl/intermediate.crl http://subca1.cyber.lab:9001/1.0/crl
```


### PHASE 5.6 : Test de la révocation

Ici nous allons démarrer les deux OCSP Responders et tester la révocation depuis le PC du recteur (Fedora) :

```sh
openssl ocsp \
  -port 2560 \
  -text \
  -index ~/pki/root/index.txt \
  -CA ~/pki/root/certs/root.crt \
  -rkey ~/pki/root/private/ocsp.key \
  -rsigner ~/pki/root/certs/ocsp.crt \
  -out ~/ocsp.log &
```

> Assurons-nous d'avoir les certificats du RootCA et du SubCA sur le PKI Server

