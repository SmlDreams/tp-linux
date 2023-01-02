# Partie 1 : Partitionnement du serveur de stockage

🌞 **Partitionner le disque à l'aide de LVM**

```bash
#je creer un PV
[dreams@storage ~]$ sudo pvcreate /dev/sdb
# je creer un VG
[dreams@storage ~]$ sudo vgcreate storage /dev/sdb
#je creer une partition ou LV
[dreams@storage ~]$ sudo lvcreate -l 100%FREE storage -n tp4_storage
```

🌞 **Formater la partition**
```bash
# je formate mon disque
[dreams@storage ~]$ sudo mkfs -t ext4 /dev/storage/tp4_storage
```

🌞 **Monter la partition**

```bash
[dreams@storage ~]$ df -h | grep tp4_storage
/dev/mapper/storage-tp4_storage  2.0G   24K  1.9G   1% /mnt/storage

#je donne les droit à mon utlisateur
[dreams@storage storage]$ sudo chown dreams /mnt/storage/

# je prouve que je peux ecrire un fichier
[dreams@storage storage]$ touch toto

# je prouve que je peux lire un fichier
[dreams@storage storage]$ cat toto
```

```bash
[dreams@storage storage]$ cat /etc/fstab | grep tp4_storage
/dev/storage/tp4_storage /mnt/storage ext4 defaults 0 0
```

# Partie 2 : Serveur de partage de fichiers

🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

```
[dreams@storage storage]$ cat /etc/exports
/storage/site_web_1 10.4.1.9(ro)
/storage/site_web_2 10.4.1.9(ro)
```

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

```
[dreams@web ~]$ cat /etc/fstab | grep 10.4.1.10
10.4.1.10:/storage/site_web_1    /var/www/site_web_1   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
10.4.1.10:/storage/site_web_2    /var/www/site_web_2   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```

# Partie 3 : Serveur web

🌞 **Installez NGINX**

```
sudo dnf install nginx
```

🌞 **Analysez le service NGINX**

```
[dreams@web ~]$ ps -ef | grep nginx
root        1149       1  0 14:33 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1150    1149  0 14:33 ?        00:00:00 nginx: worker process
dreams      1156     880  0 14:34 pts/0    00:00:00 grep --color=auto nginx
```

```
[dreams@web ~]$ ss -alnpt | grep 80
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*
LISTEN 0      511             [::]:80           [::]:*
```

```
[dreams@web ~]$ cat /etc/nginx/nginx.conf | grep '^ *server {' -A 17 | grep '    includ
e /'
        include /etc/nginx/default.d/*.conf;
```

```
[dreams@web ~]$ ls -al /etc/nginx/default.d/
total 4
drwxr-xr-x. 2 root root    6 Oct 31 16:37 .
drwxr-xr-x. 4 root root 4096 Dec  6 14:11 ..
```

## 4. Visite du service web

**Et ça serait bien d'accéder au service non ?** Genre c'est un serveur web. On veut voir un site web !

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

```
[dreams@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[dreams@web ~]$ sudo firewall-cmd --reload
success
```

🌞 **Accéder au site web**

```
[dreams@web ~]$ curl 10.4.1.9 | head -3
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed            
<!doctype html>
<html>
  <head>

```

🌞 **Vérifier les logs d'accès**

```
[dreams@web ~]$ sudo cat /var/log/nginx/access.log | tail -3
10.4.1.9 - - [06/Dec/2022:15:00:21 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
10.4.1.9 - - [06/Dec/2022:15:00:27 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
10.4.1.9 - - [06/Dec/2022:15:00:40 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
```

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

```bash
#je change le port d'écoute
[dreams@web ~]$ cat /etc/nginx/nginx.conf | grep '^ *server {' -A 17 | grep ' listen'
        listen       8080;

#je redemare le service nginx
[dreams@web ~]$ sudo systemctl restart nginx

#je verifie que nginx tourne
sudo systemctl status nginx | grep Active
     Active: active (running) since Tue 2022-12-06 15:09:38 CET; 14min ago

#je verifie que les changements ont bien étais enregistré
[dreams@web ~]$ ss -alpnt | grep 8080
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*

#je ferme l'ancien ports
[dreams@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[dreams@web ~]$ sudo firewall-cmd --reload
success

#j'ouvre le nouveau port
[dreams@web ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
[dreams@web ~]$ sudo firewall-cmd --reload
success

#je verifie que j'ai accès au site avec un curl
[dreams@web ~]$ curl http://10.4.1.9:8080 | head -3
<!doctype html>
<html>
  <head>
```

🌞 **Changer l'utilisateur qui lance le service**

```bash
#je crée un nouvel utilisateur
[dreams@web ~]$ sudo useradd web -d /home/web -p root
[sudo] password for dreams:

#je modif l'utilisateur de nginx
[dreams@web ~]$ sudo cat /etc/nginx/nginx.conf | grep '^user'
user web;

#je redémare nginx
[dreams@web ~]$ sudo systemctl restart nginx

#je verifie que le service tourne bien avec le nouvel utilisateur
[dreams@web ~]$ ps -ef | grep web
web         1428    1427  0 15:41 ?        00:00:00 nginx: worker process
```

**Il est temps d'utiliser ce qu'on a fait à la partie 2 !**

🌞 **Changer l'emplacement de la racine Web**

```
[dreams@web ~]$ cat /var/www/site_web_1/index.html
laut les gar

[dreams@web ~]$ cat /etc/nginx/nginx.conf | grep '^ *server {' -A 17 | grep ' root'
        root         /var/www/site_web_1;
[dreams@web ~]$ sudo systemctl restart nginx
[dreams@web ~]$ curl 10.4.1.9:8080
laut les gar
```

## 6. Deux sites web sur un seul serveur

🌞 **Repérez dans le fichier de conf**

```
[dreams@web ~]$ cat /etc/nginx/nginx.conf | grep '^ *server {' -A 17 | grep '    includ
e /'
        include /etc/nginx/default.d/*.conf;
```

🌞 **Créez le fichier de configuration pour le premier site**

```
[dreams@web ~]$ sudo cat /etc/nginx/conf.d/site_web_1.conf
 server {
        listen       8080;
        server_name  _;
        root         /var/www/site_web_1;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

🌞 **Créez le fichier de configuration pour le deuxième site**

```
[dreams@web ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[dreams@web ~]$ sudo firewall-cmd --reload
success
[dreams@web ~]$ sudo cat /etc/nginx/conf.d/site_web_2.conf
[dreams@web ~]$ sudo cat /etc/nginx/conf.d/site_web_1.conf
 server {
        listen       8888;
        server_name  _;
        root         /var/www/site_web_2;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

🌞 **Prouvez que les deux sites sont disponibles**

```
[dreams@web ~]$ curl 10.4.1.9:8888
laut les gar
[dreams@web ~]$ curl 10.4.1.9:8080
laut les gar
```

