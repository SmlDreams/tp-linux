# Partie 1 : Mise en place et maîtrise du serveur Web

## 1. Installation

🌞 **Installer le serveur Apache**

```bash
#j'installe le service
[dreams@weblinuxtp5 ~]$ sudo dnf install httpd -y
[...]

#je trouve le fichier de conf
[dreams@weblinuxtp5 ~]$ sudo cat /etc/httpd/conf/httpd.conf | head -5

ServerRoot "/etc/httpd"

Listen 80

```

🌞 **Démarrer le service Apache**

```bash
#je demarre le service
[dreams@weblinuxtp5 ~]$ sudo systemctl start httpd

#je verifie bien qu'il est "Active" et je note le ports sur lequel le service tourne
sudo systemctl status httpd | grep Active
     Active: active (running) since Mon 2022-12-12 15:13:49 CET; 2min 16s ago
[dreams@weblinuxtp5 ~]$ sudo ss -alpnt | grep httpd
LISTEN 0      511                *:80              *:*    users:(("httpd",pid=709,fd=4),("httpd",pid=708,fd=4),("httpd",pid=707,fd=4),("httpd",pid=687,fd=4))

#je fais en sorte que le service démarre automatiquement au démarrage
[dreams@weblinuxtp5 ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.

#j'ouvre le port correspondant (80)
[dreams@weblinuxtp5 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[dreams@weblinuxtp5 ~]$ sudo firewall-cmd --reload
success
```

🌞 **TEST**

```bash
#je verifie bien qu'il est "Active"
sudo systemctl status httpd | grep Active
     Active: active (running) since Mon 2022-12-12 15:13:49 CET; 2min 16s ago

#je fais un reboot et je verifie qu'il est active
[dreams@weblinuxtp5 ~]$ sudo reboot
[dreams@weblinuxtp5 ~]$ sudo systemctl status httpd | grep Active
     Active: active (running) since Mon 2022-12-12 16:09:08 CET; 1min 42s ago

#je verifie avec un curl que je peux me connecter localement au server
[dreams@weblinuxtp5 ~]$ curl 10.105.1.11:80 | head
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```
```
$ curl 10.105.1.11:80 | head -5

<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>


```
## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

```
[dreams@weblinuxtp5 ~]$ cat /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

```
[dreams@weblinuxtp5 ~]$ cat /etc/httpd/conf/httpd.conf | grep 'User' | head -1
User apache
```
```
[dreams@weblinuxtp5 ~]$ ps -ef | grep apache | head -4
apache       710     685  0 16:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       712     685  0 16:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       713     685  0 16:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       714     685  0 16:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```
```
[dreams@weblinuxtp5 ~]$ ls -al /usr/share/testpage/index.html
-rw-r--r--. 1 root root 7620 Jul 27 20:05 /usr/share/testpage/index.html
```

🌞 **Changer l'utilisateur utilisé par Apache**

```
[dreams@weblinuxtp5 ~]$ cat /etc/passwd | grep toto
toto:x:1001:1001::/usr/share/httpd:/sbin/nologin

[dreams@weblinuxtp5 ~]$ cat /etc/httpd/conf/httpd.conf | grep User | head -1
User toto

[dreams@weblinuxtp5 ~]$ sudo systemctl restart httpd

[dreams@weblinuxtp5 ~]$ ps -ef | grep toto | head -4
toto        1504    1503  0 16:32 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        1505    1503  0 16:32 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        1506    1503  0 16:32 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        1507    1503  0 16:32 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

🌞 **Faites en sorte que Apache tourne sur un autre port**

```
[dreams@weblinuxtp5 ~]$ cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 14331

[dreams@weblinuxtp5 ~]$ sudo firewall-cmd --add-port=14331/tcp --permanent
success
[dreams@weblinuxtp5 ~]$ sudo firewall-cmd --reload
success

[dreams@weblinuxtp5 ~]$ sudo systemctl restart httpd

[dreams@weblinuxtp5 ~]$ sudo ss -alpnt | grep httpd
LISTEN 0      511                *:14331            *:*    users:(("httpd",pid=1780,fd=4),("httpd",pid=1779,fd=4),("httpd",pid=1778,fd=4),("httpd",pid=1775,fd=4))

[dreams@weblinuxtp5 ~]$ curl 10.105.1.11:14331 | head -3

<!doctype html>
<html>
  <head>
```

# Partie 2 : Mise en place et maîtrise du serveur de base de données

🌞 **Install de MariaDB sur `db.tp5.linux`**

```
[dreams@dblinuxtp5 ~]$ sudo dnf install mariadb-server

[dreams@dblinuxtp5 ~]$ systemctl enable mariadb

[dreams@dblinuxtp5 ~]$ sudo systemctl start mariadb

[dreams@dblinuxtp5 ~]$ sudo mysql_secure_installation
```

🌞 **Port utilisé par MariaDB**

```
[dreams@dblinuxtp5 ~]$ sudo ss -alpnt | grep maria
[sudo] password for dreams:
LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=3482,fd=18))

[dreams@dblinuxtp5 ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[dreams@dblinuxtp5 ~]$ sudo firewall-cmd --reload
success
```

🌞 **Processus liés à MariaDB**

```
[dreams@dblinuxtp5 ~]$ ps -ef | grep maria | head -1
mysql       3482       1  0 16:53 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
```

# Partie 3 : Configuration et mise en place de NextCloud


## 1. Base de données

🌞 **Préparation de la base pour NextCloud**

```sql
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.12' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 0 rows affected, 1 warning (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.12';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)
```

🌞 **Exploration de la base de données**


```
[dreams@weblinuxtp5 ~]$ mysql -u nextcloud -h 10.105.1.12 -p


mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> USE nextcloud;
Database changed

mysql> SHOW TABLES
    ->
```

🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

```
MariaDB [(none)]> select user,host from mysql.user;
+-------------+-------------+
| User        | Host        |
+-------------+-------------+
| nextcloud   | 10.105.1.11 |
| mariadb.sys | localhost   |
| mysql       | localhost   |
| root        | localhost   |
+-------------+-------------+
4 rows in set (0.001 sec)
```

## 2. Serveur Web et NextCloud

⚠️⚠️⚠️ **N'OUBLIEZ PAS de réinitialiser votre conf Apache avant de continuer. En particulier, remettez le port et le user par défaut.**

🌞 **Install de PHP**

```bash
# On ajoute le dépôt CRB
[dreams@weblinuxtp5 ~]$ sudo dnf config-manager --set-enabled crb
# On ajoute le dépôt REMI
[dreams@weblinuxtp5 ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

# On liste les versions de PHP dispos, au passage on va pouvoir accepter les clés du dépôt REMI
[dreams@weblinuxtp5 ~]$ dnf module list php

# On active le dépôt REMI pour récupérer une version spécifique de PHP, celle recommandée par la doc de NextCloud
[dreams@weblinuxtp5 ~]$ sudo dnf module enable php:remi-8.1 -y

# Eeeet enfin, on installe la bonne version de PHP : 8.1
[dreams@weblinuxtp5 ~]$ sudo dnf install -y php81-php
```

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```bash
# eeeeet euuuh boom. Là non plus j'ai pas pondu ça, c'est la doc :
[dreams@weblinuxtp5 ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
```

🌞 **Récupérer NextCloud**

```
[dreams@weblinuxtp5 ~]$ sudo sudo mkdir /var/www/tp5_nextcloud

[dreams@weblinuxtp5 ~]$ curl -o nextcloud https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip

[dreams@weblinuxtp5 ~]$ sudo dnf install unzip

[dreams@weblinuxtp5 ~]$ unzip nextcloud -d /var/www/tp5_nextcloud/

[dreams@weblinuxtp5 ~]$ sudo mv  /var/www/tp5_nextcloud/nextcloud/* /var/www/tp5_nextcloud/

[dreams@weblinuxtp5 ~]$ sudo mv  /var/www/tp5_nextcloud/nextcloud/.* /var/www/tp5_nextcloud/

[dreams@weblinuxtp5 ~]$ sudo rm -rf  /var/www/tp5_nextcloud/nextcloud/

[dreams@weblinuxtp5 ~]$ sudo chown apache /var/www/tp5_nextcloud 

[dreams@weblinuxtp5 ~]$ sudo chown apache /var/www/tp5_nextcloud/*

[dreams@weblinuxtp5 ~]$ sudo chown apache /var/www/tp5_nextcloud/.*
```

🌞 **Adapter la configuration d'Apache**

```
[dreams@weblinuxtp5 ~]$ cat /etc/httpd/conf/httpd.conf | grep 'Include '
Include conf.modules.d/*.conf

[dreams@weblinuxtp5 ~]$ sudo cat /etc/httpd/conf.modules.d/tp5_nextcloud.conf
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

🌞 **Redémarrer le service Apache** pour qu'il prenne en compte le nouveau fichier de conf

```
[dreams@weblinuxtp5 ~]$ sudo systemctl restart httpd
```

## 3. Finaliser l'installation de NextCloud

➜ **Sur votre PC**

- modifiez votre fichier `hosts` (oui, celui de votre PC, de votre hôte)
  - pour pouvoir joindre l'IP de la VM en utilisant le nom `web.tp5.linux`
- avec un navigateur, visitez NextCloud à l'URL `http://web.tp5.linux`
  - c'est possible grâce à la modification de votre fichier `hosts`
- on va vous demander un utilisateur et un mot de passe pour créer un compte admin
  - ne saisissez rien pour le moment
- cliquez sur "Storage & Database" juste en dessous
  - choisissez "MySQL/MariaDB"
  - saisissez les informations pour que NextCloud puisse se connecter avec votre base
- saisissez l'identifiant et le mot de passe admin que vous voulez, et validez l'installation

🌴 **C'est chez vous ici**, baladez vous un peu sur l'interface de NextCloud, faites le tour du propriétaire :)

🌞 **Exploration de la base de données**

- connectez vous en ligne de commande à la base de données après l'installation terminée
- déterminer combien de tables ont été crées par NextCloud lors de la finalisation de l'installation
  - ***bonus points*** si la réponse à cette question est automatiquement donnée par une requête SQL