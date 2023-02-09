# Module 1 : Reverse Proxy

# I. Setup

➜ **On utilisera NGINX comme reverse proxy**

- installer le paquet `nginx` :
```
[dreams@revproxy ~]$ sudo dnf install nginx
```
- démarrer le service `nginx` :
```
[dreams@revproxy ~]$ sudo systemctl start nginx
```
- utiliser la commande `ss` pour repérer le port sur lequel NGINX écoute :
```
[dreams@revproxy ~]$ sudo ss -alnpt | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=1068,fd=6),("nginx",pid=1067,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=1068,fd=7),("nginx",pid=1067,fd=7))
```
- ouvrir un port dans le firewall pour autoriser le trafic vers NGINX :
```
[dreams@revproxy ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[dreams@revproxy ~]$ sudo firewall-cmd --reload
success
```
- utiliser une commande `ps -ef` pour déterminer sous quel utilisateur tourne NGINX :
```
[dreams@revproxy ~]$ ps -ef | grep /usr/sbin/nginx
root        1067       1  0 15:20 ?        00:00:00 nginx: master process /usr/sbin/nginx
```
- vérifier que le page d'accueil NGINX est disponible en faisant une requête HTTP sur le port 80 de la machine :
```
$ curl -s 10.105.1.13:80 | head -3
<!doctype html>
<html>
  <head>
```

➜ **Configurer NGINX**

sur le serveur rev proxy
```
[dreams@revproxy default.d]$ cd /etc/nginx/conf.d/
[dreams@revproxy default.d]$ sudo vim revproxy.conf
[dreams@revproxy default.d]$ sudo cat /etc/nginx/conf.d/revproxy.conf | head -10
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name web.tp6.linux;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
```
sur web.tp6.linux
```
[dreams@weblinuxtp5 ~]$ sudo cat /var/www/tp5_nextcloud/config/config.php | grep 10.105.1.13
          1 => '10.105.1.13',
```

➜ **Faites en sorte de**

```
[dreams@weblinuxtp5 ~]$ sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="10.105.1.13" port port="80" protocol="tcp" accept'
[dreams@weblinuxtp5 ~]$ sudo firewall-cmd --remove-port=80/tcp
```

➜ **Une fois que c'est en place**

```bash
#ping sur proxy.TP6.linux
PS C:\Users\quentin> ping 10.105.1.13

Envoi d’une requête 'Ping'  10.105.1.13 avec 32 octets de données :
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64

Statistiques Ping pour 10.105.1.13:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 0ms, Moyenne = 0ms


#ping sur web.TP6.linux
PS C:\Users\quentin> ping 10.105.1.11

Envoi d’une requête 'Ping'  10.105.1.11 avec 32 octets de données :
Délai d’attente de la demande dépassé.
```

# II. HTTPS

```
[dreams@revproxy ~]$ openssl req -nodes -newkey rsa:2048 -sha256 -keyout myserver.key -out server.csr -utf8
[dreams@revproxy ~]$ ls
myserver.key  server.csr
[dreams@revproxy ~]$ sudo cat /etc/nginx/conf.d/revproxy.conf | tail -5
    }
    listen 443;
    ssl_certificate /home/dreams/server.crt;
    ssl_certificate_key /home/dreams/myserver.key;
}
[dreams@revproxy ~]$ sudo firewall-cmd --add-port=443/tcp --permanent
success
[dreams@revproxy ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[dreams@revproxy ~]$ sudo firewall-cmd --reload
success
```