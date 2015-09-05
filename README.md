# olixshmodule-ubuntu
Module for oliXsh : Installation and configuration of Ubuntu Server



### Initialisation du module

**Pré-requis** :

Récuperer d'abord les fichiers de configuration nécessaires à l'installation du server

Command : `olixsh ubuntu synccfg pull <user>@<host>:/<path> <destination>`

Initialiser le module

Command : `olixsh ubuntu init [--force]`

Entrer les informations suivantes :
- L'emplacement du fichier de configuration (*/path/file.yml*)
- Le serveur distant de dépôt de la configuration (*user@host:/path*)
- Le port de ce même serveur



### Installation et configuration des packages du serveur

Command : `olixsh ubuntu install <packages...> [--all]`

- `packages` : Liste des packages à installer
- `--all` : Pour installer tous les packages



### Configuration des packages du serveur

Command : `olixsh ubuntu config <package>`

- `package` : Nom du package à configurer



### Sauvegarde des fichiers de configuration des packages du serveur

Copie des fichiers de configuration dans */etc* dans le dépôt local

Command : `olixsh ubuntu savecfg <packages...> [--all]`

- `packages` : Liste des packages à sauvegarder
- `--all` : Pour sauvegarder tous les packages



### Synchronisation de la configuration des packages avec un autre serveur

Synchronise le dépôt local du serveur des fichiers de configuration avec un dépôt distant.

Si le module a été initialisé, les paramètres deviennent facultatifs
et les valeurs par défaut sont ceux dans `/etc/olixsh/ubuntu.conf`

**Récupère la configuration depuis un serveur distant**

Command : `olixsh ubuntu synccfg pull [<user>@<host>:/<path>] [<destination>] [--port=22]`

- `user` : Nom de l'utilisateur de connexion au serveur de dépôt
- `host` : Host du serveur de dépôt
- `path` : Chemin où se trouvent les fichiers de configuration sur le serveur distant
- `destination` : Chemin local où seront déposés les fichiers
- `--port=` : Port du serveur de dépôt

Commande avec module initialisé : `olixsh ubuntu synccfg pull`

**Pousse la configuration vers un serveur distant**

Command : `olixsh ubuntu synccfg push [<user>@<host>:/<path>] [--port=22]`

- `user` : Nom de l'utilisateur de connexion au serveur de dépôt
- `host` : Host du serveur de dépôt
- `path` : Chemin où se trouvent les fichiers de configuration sur le serveur distant
- `--port=` : Port du serveur de dépôt

Commande avec module initialisé : `olixsh ubuntu synccfg push`

