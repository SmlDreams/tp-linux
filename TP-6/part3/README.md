# Module 3 : Fail2Ban

🌞 Faites en sorte que :

- si quelqu'un se plante 3 fois de password pour une co SSH en moins de 1 minute, il est ban :
```
[dreams@weblinuxtp5 ~]$ sudo dnf install epel-release

[dreams@weblinuxtp5 ~]$ sudo dnf install fail2ban fail2ban-firewalld

[dreams@weblinuxtp5 ~]$ sudo systemctl start fail2ban

[dreams@weblinuxtp5 ~]$ sudo systemctl enable fail2ban

[dreams@weblinuxtp5 ~]$ sudo systemctl status fail2ban

● fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; enabled; vendor preset: disabled)
     Active: active (running) since Sun 2023-01-15 13:01:00 CET; 1s ago

[dreams@weblinuxtp5 ~]$ sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

[dreams@weblinuxtp5 ~]$ sudo cat /etc/fail2ban/jail.local | grep '^bantime' | tail -1
bantime      = 1h

[dreams@weblinuxtp5 ~]$ sudo cat /etc/fail2ban/jail.local | grep '^findtime' | head -1
findtime     = 1m

[dreams@weblinuxtp5 ~]$ sudo mv /etc/fail2ban/jail.d/00-firewalld.conf /etc/fail2ban/jail.d/00-firewalld.local

[dreams@weblinuxtp5 ~]$ sudo systemctl restart fail2ban

[dreams@weblinuxtp5 ~]$ [dreams@dblinuxtp5 ~]$ sudo cat /etc/fail2ban/jail.d/sshd.local
[sshd]
enabled = true

# Override the default global configuration
# for specific jail sshd
bantime = 1d
maxretry = 3

[dreams@weblinuxtp5 ~]$ sudo systemctl restart fail2ban
```

- vérifiez que ça fonctionne en vous faisant ban :
```
[dreams@weblinuxtp5 ~]$ ssh dreams@10.105.1.12
dreams@10.105.1.12's password:
Permission denied, please try again.
dreams@10.105.1.12's password:
Permission denied, please try again.
dreams@10.105.1.12's password:
dreams@10.105.1.12: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).
[dreams@weblinuxtp5 ~]$ ssh dreams@10.105.1.12
ssh: connect to host 10.105.1.12 port 22: Connection refused
```
- utilisez une commande dédiée pour lister les IPs qui sont actuellement ban :
```
[dreams@dblinuxtp5 ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 1
|  |- Total failed:     8
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 1
   |- Total banned:     2
   `- Banned IP list:   10.105.1.11
```
- lever le ban avec une commande liée à fail2ban
```
sudo fail2ban-client unban 10.105.1.11
```

> Vous pouvez vous faire ban en effectuant une connexion SSH depuis `web.tp6.linux` vers `db.tp6.linux` par exemple, comme ça vous gardez intacte la connexion de votre PC vers `db.tp6.linux`, et vous pouvez continuer à bosser en SSH.
