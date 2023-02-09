# Module 2 : Sauvegarde du système de fichiers

## I. Script de backup

### 1. Ecriture du script

🌞 **Ecrire le script `bash`**

```
[dreams@weblinuxtp5 ~]$ cd /srv/
[dreams@weblinuxtp5 srv]$ sudo touch tp6_backup.sh
[dreams@weblinuxtp5 srv]$ sudo chmod +x /srv/tp6_backup.sh
```

```bash
#!/bin/bash
#SMl_Dreams
#10/01/2023
#sauvegarder les fichier de conf important
fileName="nextcloud_$(date +%Y%m%d%H%M%S).tar.gz"
tar -czf /srv/backup/$fileName /var/www/tp5_nextcloud/
echo "Filename : $fileName saved in /srv/backup"
```

➜ **Environnement d'exécution du script**

```bash
#creation d'un nouvel utilisateur
[dreams@weblinuxtp5 ~]$ sudo useradd backup -d /srv/backup -s /usr/bin/nologin
#modification de l'apartenance des fichier 
[dreams@weblinuxtp5 ~]$ chown backup /srv/backup/
```

```bash
[dreams@weblinuxtp5 ~]$ sudo -u backup /srv/tp6_backup.sh
[sudo] password for dreams:
/srv/tp6_backup.sh: line 6: tar: command not found
Filename : nextcloud_20230115092537.tar.gz saved in /srv/backup
```

### 3. Service et timer

🌞 **Créez un *service*** système qui lance le script

- inspirez-vous des *services* qu'on a créés et/ou manipulés jusqu'à maintenant
- la seule différence est que vous devez rajouter `Type=oneshot` dans la section `[Service]` pour indiquer au système que ce service ne tournera pas à l'infini (comme le fait un serveur web par exemple) mais se terminera au bout d'un moment
- vous appelerez le service `backup.service`
- assurez-vous qu'il fonctionne en utilisant des commandes `systemctl`

```bash
$ sudo systemctl status backup
$ sudo systemctl start backup
```

🌞 **Créez un *timer*** système qui lance le *service* à intervalles réguliers

- le fichier doit être créé dans le même dossier
- le fichier doit porter le même nom
- l'extension doit être `.timer` au lieu de `.service`
- ainsi votre fichier s'appellera `backup.timer`
- la syntaxe est la suivante :

```systemd
[Unit]
Description=Run service X

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
```

> [La doc Arch est cool à ce sujet.](https://wiki.archlinux.org/title/systemd/Timers)

🌞 Activez l'utilisation du *timer*

- vous vous servirez des commandes suivantes :

```bash
# demander au système de lire le contenu des dossiers de config
# il découvrira notre nouveau timer
$ sudo systemctl daemon-reload

# on peut désormais interagir avec le timer
$ sudo systemctl start backup.timer
$ sudo systemctl enable backup.timer
$ sudo systemctl status backup.timer

# il apparaîtra quand on demande au système de lister tous les timers
$ sudo systemctl list-timers
```

## II. NFS

### 1. Serveur NFS

> On a déjà fait ça au TP4 ensemble :)

🖥️ **VM `storage.tp6.linux`**

**N'oubliez pas de dérouler la [📝**checklist**📝](../../2/README.md#checklist).**

🌞 **Préparer un dossier à partager sur le réseau** (sur la machine `storage.tp6.linux`)

- créer un dossier `/srv/nfs_shares`
- créer un sous-dossier `/srv/nfs_shares/web.tp6.linux/`

> Et ouais pour pas que ce soit le bordel, on va appeler le dossier comme la machine qui l'utilisera :)

🌞 **Installer le serveur NFS** (sur la machine `storage.tp6.linux`)

- installer le paquet `nfs-utils`
- créer le fichier `/etc/exports`
  - remplissez avec un contenu adapté
  - j'vous laisse faire les recherches adaptées pour ce faire
- ouvrir les ports firewall nécessaires
- démarrer le service
- je vous laisse check l'internet pour trouver [ce genre de lien](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-rocky-linux-9) pour + de détails

### 2. Client NFS

🌞 **Installer un client NFS sur `web.tp6.linux`**

- il devra monter le dossier `/srv/nfs_shares/web.tp6.linux/` qui se trouve sur `storage.tp6.linux`
- le dossier devra être monté sur `/srv/backup/`
- je vous laisse là encore faire vos recherches pour réaliser ça !
- faites en sorte que le dossier soit automatiquement monté quand la machine s'allume

🌞 **Tester la restauration des données** sinon ça sert à rien :)

- livrez-moi la suite de commande que vous utiliseriez pour restaurer les données dans une version antérieure

![Backup everything](../pics/backup_everything.jpg)