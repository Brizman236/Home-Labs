
## Objectif du LAB

L'objectif est simple, me permettre de résoudre de mapper les adresses IPs de mes prochaines machines virtuelles que je déployerai dans des labs futurs avec des noms de domaine pour m'éviter à chaque fois de taper des adresses IP.

Le DNS m'est aussi utile pour des LABs réalistes comme un lab sur la PKI. Ce lab est en réalité une mise en place de l'environnement pour le LAB PKI que je ferai plutard.

___

### **Le flux du DNS**

**Ordre Logique du flux** :

```
Resolver → Root → TLD → Authoritative → Réponse finale
```

Le **DNS Resolver** est le logiciel qui innitie la achemine la requête et la réponse DNS, il est peut-être celui de notre **OS**, du routeur ou un Resolver public comme **Cloudflare**. Son rôle est de **recevoir** notre requête, trouver la réponse et nous l'a renvoyée.

Le **Root** est le serveur au sommet de la hierarchie DNS, il ne fait pas de mapping entre nom de domaine et adresse IP, son rôle est de rediriger les requêtes DNS vers les serveurs gérants les extensions(.com, .fr, .org, etc), les **TLD**

Le **TLD** ou **Top Level Domain** est le serveur gérant une extension spécifique. Par exemple un **TLD** gérant l'extension `.com` repertorie tous les adresses des serveurs autoritaires gérant une zone DNS spécifique. Il dit : " Pour  `example.com`  voici le serveur autoritaire".

Le **Authoritative Server** est celui qui dispose de toutes les adresses IP liées à un domaine spécifique. 

Illustrons tout cela avec un scénarion. Bob souhaite accéder à `example.com` . Le **Resolver** de Bob reçoit la requête DNS puis cherche le **Root Server**. Ce dernier achemine la requête à un **TLD** gérant l'extension `.com` . Le **TLD** poursuit en redirigeant la requête vers le **Authoritative Server** de `example.com` . L'adresse IP y est trouvée et ramené à Bob.

___

**Hyperviseur utilisé : Qemu**
**OS: Ubuntu Server**

___

## Etape 1 : Configuration d'une adresse IP static avec `netplan`

```sh
sudo nano /etc/netplan/50-cloud-init.yaml
```

```yml
network:
  version: 2
  ethernets:
    enp1s0:
      dhcp4: no
      addresses: [192.168.122.10/24]
      routes:
        - to: default
          via: 192.168.122.1
      nameservers:
        addresses: [1.1.1.1, 127.0.0.1]
```

```sh
sudo netplan apply
```

___

## Etape 2 : Installation de bind9

```sh
sudo apt install bind9 bind9-dnsutils bind9-doc
```

___

## Etape 3 : Déclaration de la zone DNS

```sh
# Editer le fichier named.conf.local responsable des zones DNS
sudo nano /etc/bind/named.conf.local
```

```cnf
zone "cyber.lab" {
    type master;
    file "/etc/bind/db.cyber.lab";
};
```

- **Zone DNS** : `cyber.lab`
- **Fichier de zone** : `db.cyber.lab` contenant les enregistrements DNS (à créer)

```sh
# Création de la zone DNS
sudo touch db.cyber.lab
```

Configuration des enregistrements DNS
```
$TTL 604800
@   IN  SOA dns.cyber.lab. admin.cyber.lab. (
        1         ; Serial
        604800    ; Refresh
        86400     ; Retry
        2419200   ; Expire
        604800 )  ; Negative Cache TTL

@       IN  NS      dns.cyber.lab.
dns     IN  A       192.168.122.10
```

Gestion des propriétés sur les fichiers et dossiers :

```sh
sudo chown -R bind:bind /etc/bind
sudo chown -R bind:bind /var/cache/bind
```