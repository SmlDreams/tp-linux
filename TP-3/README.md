# TP 3 : We do a little scripting

# I. Script carte d'identité

## Rendu

📁 **Fichier `/srv/idcard/idcard.sh`**

🌞 **Vous fournirez dans le compte-rendu**, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

```
[dreams@tp3-linux ~]$ /srv/idcard/idcard.sh

Machine name : tp3-linux
OS Rocky Linux release 9.0 (Blue Onyx) and kernel version is Linux 5.14.0-70.26.1.el9_0.x86_64
IP : 10.105.1.100/24
RAM : 687Mi memory available on 960Mi total memory
Disk : 5.1G space left
Top 5 processes by RAM usage :
 - /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid
 - /usr/sbin/NetworkManager --no-daemon
 - /usr/lib/systemd/systemd --switched-root --system --deserialize 27
 - /usr/lib/systemd/systemd --user
 - sshd: dreams [priv]
liste:wqning ports
 - udp 323 :
 - tcp 22 :
Here is your random cat : ./cat.jpg
```

# II. Script youtube-dl

## Rendu

📁 **Le script `/srv/yt/yt.sh`**

📁 **Le fichier de log `/var/log/yt/download.log`**, avec au moins quelques lignes

🌞 Vous fournirez dans le compte-rendu, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

```
[dreams@tp3-linux ~]$ bash /srv/yt/yt.sh https://www.youtube.com/watch?v=jjs27jXL0Zs
Video https://www.youtube.com/watch?v=jjs27jXL0Zs was downloaded.
File path : /srv/yt/downloads/SI LA VIDÉO DURE 1 SECONDE LA VIDÉO S'ARRÊTE/SI LA VIDÉO DURE 1 SECONDE LA VIDÉO S'ARRÊTE.mp4
```