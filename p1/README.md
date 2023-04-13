# Prérequis
Avant de commencer, assurez-vous d'avoir les éléments suivants installés sur votre machine:

- Vagrant
- VirtualBox

# Configuration
Pour déployer Vagrant et k3s, suivez les étapes suivantes:

1. Dans le fichier configs.json, configurez les paramètres suivants pour chaque machine virtuelle:
- ```name```: le nom de la machine virtuelle.
- ```hostname```: le nom d'hôte de la machine virtuelle.
- ```ip```: l'adresse IP de la machine virtuelle.
- ```cpu```: le nombre de cœurs de processeur alloués à la machine virtuelle.
- ```ram```: la quantité de mémoire vive allouée à la machine virtuelle.
2. Ouvrez le fichier install.sh et vérifiez que les chemins d'accès des clés ssh correspondent bien à ceux indiqués dans le fichier configs.json.
4. Ouvrez le fichier Vagrantfile et vérifiez que le chemin d'accès au fichier configs.json est correct.
5. Une fois la configuration terminée, ouvrez un terminal dans le dossier contenant les fichiers de configuration et exécutez les commandes suivantes:

# Déploiement
Une fois la configuration terminée, ouvrez un terminal dans le dossier contenant les fichiers de configuration et exécutez les commandes suivantes:

1. ```vagrant up``` pour créer et démarrer les machines virtuelles.
2. Attendez que l'installation de k3s soit terminée. Cela peut prendre quelques minutes.
3. Pour accéder à l'interface utilisateur de k3s, ouvrez un navigateur Web et accédez à l'URL https://192.168.56.110:6443.
4. Utilisez le nom d'utilisateur admin et le mot de passe affiché lors de l'installation de k3s pour vous connecter à l'interface utilisateur.

# Explications
```arduino
        ┌────────────┐     ┌────────────┐     ┌────────────┐
        │            │     │            │     │            │
        │   Client   │───► │   Server   │───► │  Worker 1  │
        │            │     │            │     │            │
        └────────────┘     └────────────┘     └────────────┘
                                ▲                   ▲
                                │                   │
                                │                   │
        ┌────────────┐          │                   │
        │            │          │                   │
        │   Vagrant  │◄─────────┘                   │
        │            │                              │
        └────────────┘                              │
                                ┌────────────┐      │
                                │            │      │
                                │   Worker 2 │◄─────┘
                                │            │
                                └────────────┘
```

## Vagrantfile

- ```Vagrant.configure("2") do |config|```: Cela indique que nous sommes en train de configurer une version 2 de Vagrant, et que toutes les instructions suivantes seront incluses dans cet objet de configuration.
- ```config.vm.define data["server"]["name"] do |server|``` : Cette instruction définit la première machine virtuelle nommée "server". Elle utilise le nom de la machine stocké dans le fichier de configuration JSON, et utilise le bloc do...end pour définir les paramètres de la machine virtuelle. Le paramètre server.vm.box indique l'image de la machine virtuelle à utiliser pour cette instance, stockée localement sur votre machine ou dans un référentiel distant. server.vm.network spécifie la configuration du réseau, y compris l'adresse IP. server.vm.hostname détermine le nom d'hôte de la machine virtuelle.
- ```server.vm.provider data["provider"] do |v|``` : Cette instruction spécifie le fournisseur de la machine virtuelle, dans ce cas VirtualBox, et définit les attributs du fournisseur pour cette machine. Cela peut inclure des options de mémoire, de processeur et de stockage.
- ```config.vm.define data["serverworker"]["name"] do |serverworker|``` : Cette instruction définit une deuxième machine virtuelle nommée "serverworker", utilisant les mêmes blocs do...end que la première.
- ```config.vm.provision``` : Ces instructions spécifient les fichiers à copier et les commandes à exécuter lors de la création de la machine virtuelle. Dans ce cas, ils copient les clés SSH générées et le script d'installation à l'intérieur de la machine virtuelle. La dernière instruction exécute le script d'installation.

## install.sh

1. La première ligne de commande déplace le fichier id_rsa généré précédemment dans le dossier .ssh de l'utilisateur vagrant.
2. La deuxième ligne de commande déplace le fichier id_rsa.pub généré précédemment dans le dossier .ssh de l'utilisateur vagrant.
3. La troisième ligne de commande ajoute la clé publique (id_rsa.pub) à la liste des clés autorisées (authorized_keys) de l'utilisateur vagrant pour permettre une connexion SSH sécurisée à cette machine virtuelle.
4. Les commandes suivantes modifient les permissions des fichiers de clé pour les sécuriser. Les fichiers id_rsa.pub, id_rsa et authorized_keys ont tous leurs permissions définies à 400 (lecture seule pour l'utilisateur propriétaire) pour éviter toute modification non autorisée.
5. La cinquième ligne de commande affiche l'adresse IP de l'interface réseau eth1 actuellement utilisée par la machine virtuelle.
6. Cette section contient deux blocs conditionnels pour l'installation de K3s selon que la machine virtuelle est un serveur ou un worker. Si la machine virtuelle est un serveur, la commande curl télécharge et exécute le script d'installation de K3s avec les paramètres spécifiés. Si la machine virtuelle est un worker, le script récupère le jeton de connexion auprès du serveur maître K3s, puis configure les variables d'environnement K3S_TOKEN et K3S_URL avec les informations du serveur maître, avant d'exécuter également le script d'installation de K3s.
7. Enfin, la dernière ligne de commande attend 15 secondes pour permettre au serveur maître de terminer son initialisation.
