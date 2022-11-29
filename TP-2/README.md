# TP2 : Appréhender l'environnement Linux

# I. Service SSH

## 1. Analyse du service

On va, dans cette première partie, analyser le service SSH qui est en cours d'exécution.

🌞 **S'assurer que le service `sshd` est démarré**

    ```
    systemctl status sshd

    Active: active (running) since Tue 2022-11-22 15:23:20 CET; 6min ago
    ```

🌞 **Analyser les processus liés au service SSH**

```
[dreams@tp-2-linux ~]$ ps -ef | grep sshd

root         709       1  0 15:23 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         855     709  0 15:25 ?        00:00:00 sshd: dreams [priv]
dreams       859     855  0 15:25 ?        00:00:00 sshd: dreams@pts/0
dreams       895     860  0 15:31 pts/0    00:00:00 grep --color=auto sshd
```

🌞 **Déterminer le port sur lequel écoute le service SSH**

```
[dreams@tp-2-linux ~]$ ss | grep ssh
tcp   ESTAB  0      52                        10.4.1.6:ssh           10.4.1.1:49836
```

🌞 **Consulter les logs du service SSH**

```
[dreams@tp-2-linux log]$ sudo tail secure

Nov 22 15:23:30 tp-2-linux login[723]: pam_unix(login:session): session opened for user dreams(uid=1000) by (uid=0)
Nov 22 15:23:30 tp-2-linux login[723]: LOGIN ON tty1 BY dreams
Nov 22 15:25:34 tp-2-linux sshd[855]: Accepted password for dreams from 10.4.1.1 port 49836 ssh2
Nov 22 15:25:34 tp-2-linux sshd[855]: pam_unix(sshd:session): session opened for user dreams(uid=1000) by (uid=0)
Nov 22 15:27:16 tp-2-linux sudo[881]:  dreams : TTY=pts/0 ; PWD=/home/dreams ; USER=root ; COMMAND=/bin/nano /etc/resolv.conf
Nov 22 15:27:16 tp-2-linux sudo[881]: pam_unix(sudo:session): session opened for user root(uid=0) by dreams(uid=1000)
Nov 22 15:27:20 tp-2-linux sudo[881]: pam_unix(sudo:session): session closed for user root
Nov 22 15:41:53 tp-2-linux sudo[909]:  dreams : TTY=pts/0 ; PWD=/var/log ; USER=root ; COMMAND=/bin/cat secure
Nov 22 15:41:53 tp-2-linux sudo[909]: pam_unix(sudo:session): session opened for user root(uid=0) by dreams(uid=1000)
Nov 22 15:41:53 tp-2-linux sudo[909]: pam_unix(sudo:session): session closed for user root
```

## 2. Modification du service

🌞 **Identifier le fichier de configuration du serveur SSH**

```
sshd_config
```

🌞 **Modifier le fichier de conf**

```
[dreams@tp-2-linux log]$ echo $RANDOM
27595
```
```
[dreams@tp-2-linux log]$ sudo cat /etc/ssh/sshd_config | grep Port
Port 27595
```
```
[dreams@tp-2-linux log]$ sudo firewall-cmd --remove-port=22/tcp --permanent
success
[dreams@tp-2-linux log]$ sudo firewall-cmd --add-port=27595/tcp --permanent
success
[dreams@tp-2-linux log]$ sudo firewall-cmd --reload
[dreams@tp-2-linux log]$ sudo firewall-cmd --list-all | grep ports
  ports: 27595/tcp
  ```
🌞 **Redémarrer le service**

```
systemctl restart sshd
```

🌞 **Effectuer une connexion SSH sur le nouveau port**

```
PS C:\Users\quentin> ssh dreams@10.4.1.6 -p 27595
dreams@10.4.1.6's password:
[dreams@tp-2-linux ~]$
```

# II. Service HTTP


## 1. Mise en place



🌞 **Installer le serveur NGINX**

```
[dreams@tp-2-linux ~]$ sudo dnf install nginx
```

🌞 **Démarrer le service NGINX**

```
[dreams@tp-2-linux ~]$ sudo systemctl start nginx
```

🌞 **Déterminer sur quel port tourne NGINX**

```
[dreams@tp-2-linux ~]$ sudo ss -alnpt | grep nginx
LISTEN 0      511          0.0.0.0:80         0.0.0.0:*    users:(("nginx",pid=10897,fd=6),("nginx",pid=10896,fd=6))
LISTEN 0      511             [::]:80            [::]:*    users:(("nginx",pid=10897,fd=7),("nginx",pid=10896,fd=7))
```

🌞 **Déterminer les processus liés à l'exécution de NGINX**

```
[dreams@tp-2-linux ~]$ ps -ef | grep nginx
root       10896       1  0 16:14 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      10897   10896  0 16:14 ?        00:00:00 nginx: worker process
dreams     11007    1081  0 16:38 pts/0    00:00:00 grep --color=auto nginx
```

🌞 **Euh wait**

```
[dreams@tp-2-linux ~]$ curl 10.4.1.6 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
100  7620  100  7620    0     0  1488k      0 --:--:-- --:--:-- --:--:-- 1488k
curl: (23) Failed writing body
```

## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

```
[dreams@tp-2-linux ~]$ ls /etc/nginx/
```

🌞 **Trouver dans le fichier de conf**

```
[dreams@tp-2-linux ~]$ cat /etc/nginx/nginx.conf | grep '^ *server {' -A 17
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

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

```
[dreams@tp-2-linux www]$ cat /etc/nginx/nginx.conf | grep -i '^      *Include'
        include /etc/nginx/conf.d/*.conf;
```
## 3. Déployer un nouveau site web

🌞 **Créer un site web**

```
[dreams@tp-2-linux var]$ sudo mkdir www
[dreams@tp-2-linux var]$ cd www/
[dreams@tp-2-linux www]$ sudo mkdir tp2-linux
[dreams@tp-2-linux tp2-linux]$ sudo touch index.html
[dreams@tp-2-linux tp2-linux]$ sudo nano index.html

<h1>MEOW mon premier serveur web</h1>

```

🌞 **Adapter la conf NGINX**

```
[dreams@tp-2-linux conf.d]$ cat /etc/nginx/nginx.conf | grep '^ *server {' -A 17
[dreams@tp-2-linux conf.d]$
```

```

[dreams@tp-2-linux ~]$ cd /etc/nginx/default.d/
[dreams@tp-2-linux default.d]$sudo touch tp2-linux.conf
[dreams@tp-2-linux default.d]$sudo systemctl restart nginx
[dreams@tp-2-linux default.d]$ echo $RANDOM
11937
[dreams@tp-2-linux default.d]$ sudo nano tp2-linux.conf

server {
  
  listen 11937;

  root /var/www/tp2-linux;
}

[dreams@tp-2-linux default.d]$ sudo firewall-cmd --add-port=11937/tcp --permanent
success

```

🌞 **Visitez votre super site web**

```
[dreams@tp-2-linux conf.d]$ curl 10.4.1.6:11937
<h1>MEOW MEOW mon premier serveur we</h1>
```

# III. Your own services

## 2. Analyse des services existants

Un service c'est quoi concrètement ? C'est juste un processus, que le système lance, et dont il s'occupe après.

Il est défini dans un simple fichier texte, qui contient une info primordiale : la commande exécutée quand on "start" le service.

Il est possible de définir beaucoup d'autres paramètres optionnels afin que notre service s'exécute dans de bonnes conditions.

🌞 **Afficher le fichier de service SSH**

```
[dreams@tp-2-linux ~]$ cat /usr/lib/systemd/system/sshd.service | grep ExecStart
ExecStart=/usr/sbin/sshd -D $OPTIONS
```

🌞 **Afficher le fichier de service NGINX**

```
[dreams@tp-2-linux ~]$ cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
ExecStart=/usr/sbin/nginx
```

## 3. Création de service

![Create service](./pics/create_service.png)

Bon ! On va créer un petit service qui lance un `nc`. Et vous allez tout de suite voir pourquoi c'est pratique d'en faire un service et pas juste le lancer à la min.

Ca reste un truc pour s'exercer, c'pas non plus le truc le plus utile de l'année que de mettre un `nc` dans un service n_n

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

```
[dreams@tp-2-linux system]$ cat /etc/systemd/system/tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 25968
[dreams@tp-2-linux system]$
```

🌞 **Indiquer au système qu'on a modifié les fichiers de service**

```
[dreams@tp-2-linux system]$ sudo systemctl daemon-reload
```

🌞 **Démarrer notre service de ouf**

```
[dreams@tp-2-linux system]$ systemctl start tp2_nc.service
```

🌞 **Vérifier que ça fonctionne**

```
[dreams@tp-2-linux system]$ systemctl status tp2_nc.service | grep Active
     Active: active (running) since Tue 2022-11-29 10:56:36 CET; 4min 36s ago

[dreams@tp-2-linux system]$ ss -al | grep 25968
tcp   LISTEN 0      10                                        0.0.0.0:25968                   0.0.0.0:*
tcp   LISTEN 0      10                                           [::]:25968                      [::]:*

```
```
PS C:\Users\quentin\Documents\netcat-win32-1.12> ./nc64.exe 10.4.1.6 25968 -v
10.4.1.6: inverse host lookup failed: h_errno 11004: NO_DATA
(UNKNOWN) [10.4.1.6] 25968 (?) open
salut
fdzfe
```

🌞 **Les logs de votre service**

- mais euh, ça s'affiche où les messages envoyés par le client ? Dans les logs !
- `sudo journalctl -xe -u tp2_nc` pour visualiser les logs de votre service
- `sudo journalctl -xe -u tp2_nc -f ` pour visualiser **en temps réel** les logs de votre service
  - `-f` comme follow (on "suit" l'arrivée des logs en temps réel)
- dans le compte-rendu je veux
  - une commande `journalctl` filtrée avec `grep` qui affiche la ligne qui indique le démarrage du service
  - une commande `journalctl` filtrée avec `grep` qui affiche un message reçu qui a été envoyé par le client
  - une commande `journalctl` filtrée avec `grep` qui affiche la ligne qui indique l'arrêt du service

🌞 **Affiner la définition du service**

- faire en sorte que le service redémarre automatiquement s'il se termine
  - comme ça, quand un client se co, puis se tire, le service se relancera tout seul
  - ajoutez `Restart=always` dans la section `[Service]` de votre service
  - n'oubliez pas d'indiquer au système que vous avez modifié les fichiers de service :)