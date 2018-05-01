# Girofle

Cette recette provisionne Girofle sur un hôte réseau unique.

L'intention de [Girofle](#), est de permettre de gérer un ensemble d'instances [Gitlab](https://gitlab.io), dont la taille 
a pour seule limitation les capacités du matériel.

Girofle conditionne ses instances Gitlab sous la forme de conteneurs Docker.
Très simplifié, Girofle permet de faire des opérations CRUD, sur un ensemble (de cardinal quelconque) d'instances Gitlab.

`[À venir dans la prochaine release]` Une fois installé, Girofle utilise les interfaces réseau dans le système sous-jacent, mais seule celles qui lui ont été attribuées.


À la provision, Girofle commisionne une première instance Gitlab, par défaut.
La recette de provision Girofle permet de configurer les paramètres de commission de l'Instance Gitlab initiale.

Girofle est testé pour les OS suivant:
* CentOS 7


## Opérations standard d'exploitation

* `[À VENIR DANS LA PROCHAINE RELEASE]` Comissioner une nouvelle instance gitlab, (en lui donnant éventuellement un nom, qui sera suffixé dans le nom du conteneur docker), et en retour on a l'url complète vers l'instance Gitlab comissionnée.
* `[À VENIR DANS LA PROCHAINE RELEASE]` Dé-commissioner une instance gitlab (pas la détruire sauvagement).
* Lister les instances gitlab
* Faire un backup local (1,2):
  * de la configuration Girofle, 
  * de l'état Girofle.
* Faire un backup remote(1,2,3)(vers un stockage de géolocalisation différente):
  * de la configuration Girofle, 
  * de l'état Girofle.
* Pour une instance gitlab, faire un backup local (1,2)
* Pour une instance gitlab, faire un backup remote(1,2,3)(vers un stockage de géolocalisation différente)
* Pour une instance gitlab, faire un restore dans une autre VM, ou la même VM:
  * à partir d'un backup retrouvé dans le stockage de même géolocalisation, mais machine différente
  * à partir d'un backup retrouvé dans le stockage de géolocalisation différente
  * Ces bakcups / Restore 
* Pour une instance gitlab, à la comission, les backups (1,2) sont faits automatiquement (configurés comme une tâche réccurrente système crontab). Par défaut, toutes les 4 heures:
  * une opération de backup vers le répertoire `/girofle/sauvegardes` est réalisée pour l'instance Gitlab Entière.
  * par défaut, toutes les 4 heures, le répertoire `/girofle/sauvegardes` est backuppé dans le stockage de même géolocalistation, mais exploité par une machine différente

  
L'état Girofle est défini par:
* Quelles sont les instances gitlab up'n running? Quelles sont celles arrêtées?
* Quelles sont les interfaces réseau utilisées (adresses  IP / noPort IP), et le mapping entre couples (adresse_ip, no_port_ip) et instances gitlab?
* L'état de chaque instance gitlab, hormis le fait qu'elle soit ou non en service:
  * La configuration de l'instance Gitlab (`GITLAB_CONFIG_DIR=/etc/gitlab`)
  * Les logs de l'instance Gitlab (`GITLAB_LOG_DIR=/var/log/gitlab`)
  * Pour chaque repository Git dans l'instance Gitlab, doivent être backuppées:
    * Les données de repository (l'historique des commit et tags) (contenues dans `GITLAB_DATA_DIR=/var/opt/gitlab`)
    * Les données de documentation du repository (les `README.md`, contenus dans `GITLAB_DATA_DIR=/var/opt/gitlab`, et les vérifier si le wiki de chaque repo est backuppé avec `GITLAB_DATA_DIR=/var/opt/gitlab`)
	* -> Pour le backup des wikis, éventuellement créer un java qui exécute les opérations (récupération de la liste des wikis, de chaque page de chaque wiki, création d 'un wiki, etc...) de [l'API REST Gitlab](https://docs.gitlab.com/ee/api/wikis.html) permettant de faire le backup / restore des wikis de chaque repo Git d'une instance Gitlab (l'instance Gitlab définissant le endpoint de l'API).
    * La configuration de l'authentification et des autorisations des utilsateurs du repository (contenues où? configuration de l'authentification faite comment dans gitlab? À retrouver)


# Installation

Pour ce faire, exécutez, avec un utilisateur adminsitrateur, la commande suivante:

```

# mkdir doc-pms && cd doc-pms && git clone "https://github.com/Jean-Baptiste-Lasselle/girofle" . && sudo chmod +x ./operations.sh && ./operations.sh

```

Le processus d'installation de Girofle vous demandera quelques informations interactivement, come l'adresse IP que vous souhaitez que votre instance Gitlab utilise.
Le reste des opérations est automatisé.

<!-- # mkdir doc-pms && cd doc-pms && git clone "" . && sudo chmod +x ./operations.sh && ./operations.sh -->

# Client Girofle

L'utilisateur de Girofle utilisera un client.
Le client Girofle peut être  provisionné dans la machine de l'utilisateur avec les outils connus suivants:
- Chef.io,
- Ansible
- des scripts powershell et linux shell sont aussi supportés

Avec le client Girofle:
* le technicien IT pourra effectuer toutes les opérations que 'il est autorisé à faire, en vertu de la gestion des autorisations Girofle.
* le non-technicien IT pourra utiliser ce client, dans un mode dit "restreint" (mode qui est configuré à la provision du client Girofle). Dans ce mode, l'utilisateur pourra utiliser
Git pour versionner son travail sur des documents divers, comme des documents de management, ou la préparation d'une présentation. Dans ce mode restreint, l'utilisateur 
utilise un dépôt Git, en étant le seul (personne d'autre ne `commit && push` sur ce repo). Les fonctionnalités du Client Girofle sont les suivantes:
  * [save local]: en pressant ce bouton, l'utilisateur sauvegarde une nouvelle version des fichiers, dans leur état courant
  * [push remote if there are more local commits  than remote]: lorsqu'il est connecté au serveur, il peut en pressant un bouton, lancer une "synchronsiation": il s'agit d'un push Git. Que l'utilisateur non-IT voit comme un serveur de sauvegarde
  * resolve conflicts if there are more remote commits than local, with:
    * copy versioned directory to another, as backup
    * clone the remote
    * automatically present list of files missing or presenting differences
	* automatically add missing files
	* which will leave only a list of files with differences to remote
  
* On considère que l'ensemble des machine sutilisées par  un utilsiateur non IT constituent une seule et même machine.
* en plsu de son repo git, chaque répertoire est recensé dans le compte de l'utilisateur: il faut donc une application serveur, qui maintient l'inventaire des répertoires.
* L'utilsiateur non-IT versionne un répertoire sur une machine `M1`, fait des commit && push, fait des dernières modifications, mais ne fait pas le dernier commit && push.
* Il met sa machine hors tension, et passe sur une autre machine. Il tente de récupérer le répertoire, la récupération lui est refusée, aprce qu'il n'a pas fait le dernier commit && push : il reste "quelque part" (sur l'une de ses machines), des modificationsqui n'ont pas été sauvegardées.
* Il faudra gérer toutes les possibilités pour faciliter le dernier commit && push.
* L'utilisateur non IT versionne un répertoire de sa machine avec un repo. Aucun autre répertoire de sa machine ne peut être versionné par le même repo.
* Le client Girofle assure el respect de cette règle.
* De plus, l'applications erveur vérifiera que si un AUTRE utilisateur demande à récupérer le répertoire, il y est autorisé (donc un utilisateur doit poucvoir donner cette autorisation), et si autorisation il y a, alors l'applciations erveur Girofle vérifie que l'utilisateur précédent n'a pas ublié le dernier commit and push.
*  Bon, il faut qu'un tel utilisateur puisse aussi annuler les chagements qu'il a en cours: dans ce cas, je détris le répertoire et je refais un cloen entier du repo à la version voulue.
* Un truc qui n'a rien à voir, masi que je garde là parce qu'il est tard: Imaginons que j'ai des changements non commités, mais bon, il y en a beaucoup, dans plusieurs fichiers. Je sais que je veux "en gros" totu annuler, mais je veux vérifer. Ce que je voudrais alors pouvoir faire:
  * Pour chaque différence par rapport à la version précédente, je veux pouvoir l'examiner, et "préparer" une version git à lavance. Au fur et à mesure que je dépile la liste des différences, je vais probablement vouloir préparer encore d'autres versions à l'avance.
  * À la fin, j'ai préparé un sous arbre git, que je peux visualiser graphiquement. Avec cette visualisation graphique, je peux retirer n'imprte quelle version, sans changer la relation d'ordre canonique dans un arbre git. Le nouvel ordre obtenue, est un sous-ordre de l'ordre original.
L4ensemble de ces règles 
* 

# TODOs


## next

* Utiliser [ce nouveau repo](https://github.com/Jean-Baptiste-Lasselle/recette-conditionnment-java-windows) pour créer les repository nécesséaires au déploiement du client Girofle.
* Il faut isntaller les scripts d'opérations standards dans le répertoire `/girofle/operations-std`
* Il faut créer le repo Git du client Girofle dans l'instance Gitlab, et y mettre les fichiers du client girofle (les .sh, les .bat etc...)
* Il faudra en fait créer dans l'instance Gitlab Intitiale, un repo Git pour la recette de provision du client girofle pour Windows, pour CentOS, pour Ubuntu, etc... Mais aussi un pourt la rectte ansible, et un autre pour la recette Chef.io. Il y a une boucle de dépendances à démêler ici.
* re-tester les backup automatiques.



## Top-TODO

Lorsque l'on devra comissionner un conteneur gitlab, on devra "attendre", nécessairement, et en tout cas il est certain que l'on voudra pouvoir vérifier QUAND une instance gitlab est "prête":
lorsqu'elle est dans l'état "healthy". J'utiliserai donc la nouvelle fonctionnalité "`HEALTH_CHECK`" de docker-compose, pour réaliser cela.

La problématique s'est préserntée dans le cas suivant:

Lorsque l'on comissionne le conteneur docker de l'instance Gitlab:
* On démarre le conteneur docker, 
* Le `daemon` Docker affiche alors un état "starting" pour le conteneur docker, 
* Puis, on essaie immédiatement de la reconfigurer en allant chercher le fichier "/etc/gitlab/gitlab.rb" dans le conteneur
* Mais ce fichier n'est pas trouvé dans le conteneur, tant que le conteneur Docker ne notifie pas un état "healthy"
* D'autre part, en utilisant la commande `gitlab-ctl reconfigure`, on constate:
  * qu'un client chef.io est utilisé pour réaliser la reconfiguration.
  * que c'est probablement le cas aussi pendant la séquence d'amorçage du conteneur (à son démarrage)
  * et donc en prenant un peu de distance par rapport à ces constations, on peut penser que d'un point de vue général, pour Gitlab, on a le cas d'une application dans un conteneur docker, qui doit notifier le `daemon` Docker que l'application est prête, suite àç quoi Docker fait passer l'état du conteneur de "starting" à "healthy"

En conclusion:
* Girofle provisionne des conteneurs dockers identiques, ne différant que par leur configuration (et la recette de provision, ex. pour la publication DNS d'un nouveau nom de domaine)
* Donc Girofle intrinsèqumen, DOIT pouvoir effectuer (y compris intensément) des reconfiguration d 'instances en cours d'exécution. 
* Il sera donc absolument nécessaire que Girofle puisse déterminer si un conteneur est (ou non) passé dans l'état "healthy".
* pour ce faire, Girofle  utilisera la fonctionnalité `HEALTH_CHECK` des dockerfile, ce qui permettra à Girofle d'orchestrer ses opérations de re-configuration.

D'un point de vue général, le principe est qu'une application déployée, doit pouvoir envoyer une notification à l'infrastructure dans laquelle elle est déployée:
Avec cette notification, l'application informe l'infrastructure (et ses superviseurs) qu'elle est "prête à travailler".

Notes perso: après avoir mis en oeuvre la fonctionnalité `HEALTH_CHECK` de docker, il faudra faire un `gitlab-ctl reconfigure`, car j'ai pu remarquer une amélioration significative des performances de mes noeuds gitlabs après une exécution de `gitlab-ctl reconfigure`.

* Pour vérifier l'état du contenu (healthy, unhealthy, starting):
`docker inspect --format='{{json .State.Health}}' your-container-name`
* Faire le `HEALTH_CHECK` docker:
  * il s'agit d'ajouter dans le docker file une instruction, par exemple: `HEALTHCHECK --interval=5m --timeout=3s --start-period=1 --retries=17 CMD curl --fail http://localhost:3000/ || exit 1`
  * Cette instruction doit précéder la commande CMD finale du dockerfile.
* À tester: `the new orchestration features in Docker Swarm mode services are utilizing a health check to manage zero-downtime deployments.` 
* À tester:  `HEALTH_CHECK` docker et Kubernetes

La gestion du `HEALTH_CHECK` docker peut être concernée par la définition des SLA. d'une appli cloud
Et pour terminer, la gestion du `HEALTH_CHECK` docker ne peut être réalisé que pour les plateformes utilisant Docker en version supérieure ou égale à `Docker 1.12`

Ressources :

https://blog.newrelic.com/2016/08/24/docker-health-check-instruction/

https://docs.docker.com/engine/reference/builder/#/healthcheck


### Possibilité

Utiliser:
```
 sudo docker inspect -f '{{json .State.Health.Status}}' $NOM_DU_CONTENEUR_CREE
```
avec une boucle While dans un shell script, avec une instruction `sleep 10` dans la boucle, et la boucle st cassée au bout d'un certain nombre maximupm d'essai si le contneur n'entre jamais ni dans l'état "healthy, ni dans l'état "unhealthy". Si au contraire l'un de ces deux état est celui du conteneur, les opérations sont soient arrêtées, et les infos d'ereurs logguées, soit la procédure de déploiement se poursuiit avec le changement de configuration [/etc/gitlab/gitlab.rb]

cf.nouveau fichierds rep `./etc.gitlab.gitlab.rb`

## 0. Sécurité

Modifier la provision d'un certificat SSL pour le connecteur HTTPS, afin d'éviter à l'utilisateur de se faire sniffer ses mots de passe Girofle sur le réseau interne, quelque soit l'attaquant.

## 1. Sur les opérations de backup/restore

### Opérations standard d'exploitation

```
# La règle implicite est que pour chaque service gitlab, un conteneur est créé avec un nom, et un répertoire lui
# est donné : [$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER].
# Dans lequel ce répertoire on a, pour chaque conteneur, 5 sous répertoires en arbre:
# [$REPERTOIRE_GIROFLE]
#				| 
#				| 
# 		[noeud-gitlab-$GITLAB_INSTANCE_NUMBER]
# 						|
# 						|__ mapping-volumes
# 						|	   	  |__ data
# 						|	   	  |__ config
# 						|	   	  |__ log
# 						|
# 						|
# 						|__ bckups
# 						|	   |
# 						|	   |__ unedate/
# 						|	   |	  |__ data
# 						|	   |	  |__ config
# 						|	   |	  |__ log
# 						|	   |	  |
# 						|	   |	  |
# 						|	   |
# 						|	   |
# 						|	   |__ uneautredate/
# 						|	   |	  |__ data
# 						|	   |	  |__ config
# 						|	   |	  |__ log
# 						|	   |	  |
# 						|	   |	  |
# 						|	   |
# 						|	   |
# 						|	   
# 						|	      
#    
#    => les bckups devront être stockés dans [$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER/bckups]
#    
```

L'opération standard de backup, `./operations-std/serveur/restore.sh`, peut-être invoquée avec ou sans arguments en ligne de commande:
* si aucun argument n'est passé à `./operations-std/serveur/restore.sh`, il demande interactivement le nom du conteneur docker, et le chemin de son répertoire dédié (exemple: [`$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER`])
* si un seul argument est passé, alors un message d'erreur est affiché, et l'aide affichée.
 * si deux arguments sont passés, alors:
 * le premier est considéré comme étant le nom du conteneur docker (et alors s'il la commande `docker ps -a` ne renvoie pas une sortie standard contenant le nom du conteneur, une erreur est levée)
 * le second est considéré comme étant le chemin du répertoire dédié du conteneur docker, et alors une erreur est levée si les conditions suivnates ne sont pas vérifiées:
 *  le répertoire indiqué existe dans le système,
 *  le répertoire indiqué contient un répertoire de nom "mapping-volumes", qui doit contenir aussi 3 répertoires "data", "config", "log", 
    *  le répertoire indiqué contient un répertoire de nom "bckups", qui doit contenir au moins un répertoire (un backup), qui lui-même doit contenir aussi 3 répertoires "data", "config", "log"

L'opération standard de backup sauvegarde:
* Les répertoires gitlab: `data`, `config` & `log`
* Pour chaque repo Git, le wiki n'est pas inclut,
* Les fichiers README.md sont sauvegardés, parce qu'ils sont versionnés avec les autres fichiers versionnés par le dépôt Git
  
### Utilisateurs Linux provision Girofle

Modifier le provisionning Girofle, pour que le processus d'installation:
* créée un utilisateur linux qui effectue le provisioning de Girofle
* créée un utilisateur linux qui sera utilisé pour exécuter Girofle

### Conteneur Docker `girofle-provisioner`

Modifier le provisionning Girofle, pour que le processus d'installation se fasse à l'itérieur d'un conteneur Docker, dans 
lequel est fait tout ce qu'il y a à faire avec git. De cette manière, plus de git installé sur l'hôte, le conteneur de comissionning ainsi utilisé est 
détruit à la fin du commissioning, ne laissant que les logs des opérations. Ce qui permet au passage de ne pas créer d'utilisateur dédié au 
comissioning sur la machine hôte.

### Persistance inventaire

Il faudra remplacer `$INVENTAIRE_GIROFLE` par une BDD NoSQL pour régler le problème d'accès concurrent, plus essai avec /etcd

### Dépendances entre variables d'env.

Le fichier `./operations-std/serveur/restore.sh`, est pour le moment le point exact où est faite l'association entre: 

```
 $NOM_CONTENEUR_DOCKER <=> $REP_GIROFLE_CONTENEUR_DOCKER
```

`$REP_GIROFLE_CONTENEUR_DOCKER` étant le nom du répertoire dédié au conteneur $NOM_CONTENEUR_DOCKER, exemple: 

```
export REP_GIROFLE_CONTENEUR_DOCKER=$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER
```

Globalement les opérations standard utilisent donc 3 variables indépendantes:
```
 $NOM_CONTENEUR_DOCKER <=> $REP_GIROFLE_CONTENEUR_DOCKER <=> $ADRESSE_IP_DEDIEE_AU_SERVICE_GITLAB
```

Et la donnée de la valeur de ces 3 variables est suffisante à Girofle pour déduire toute autre information à propos d'une instance répertoriée dans le fichier:
```
	export INVENTAIRE_GIROFLE=$REPERTOIRE_GIROFLE/inventory.girofle
```
Dans `./operations-std/serveur/restore.sh`, c'est la variable d'environnement `$ADRESSE_IP_SRV_GITLAB` qui correspond à `$ADRESSE_IP_DEDIEE_AU_SERVICE_GITLAB`
Demander interactivement à l'utilisateur le nom du conteneur docker à backup/restore, ainsi que le chemin de son répertoire dédié

# Quarks n `gravity`

Girofle permettra de créer des multivers de galaxies Git.

Aux fonctionnalitrés [citées ci-dessus](#girofle), s'ajouteront celles du composant "`gravity`". "`gravity`" permettra:
* de construire un ensemble de repo git, les configurer (provision)
* d'exécuter une suite d'actions sur cet ensemblede repo git: Cet ensemble d'action est un test automatisé d'un "bout" de workflow.
"`gravity`" Permet donc de développer des workflows, et produira en sortie un fichier BPMN 2.0 exécutable, pour s'intégrer à [Kytes](https://github.com/Jean-Baptiste-Lasselle/kytes)
# POINT DE REPRISE
Dernière erreur:

```
Error: No such container:path: conteneur-kytes.io.gitlab.1:/etc/gitlab/gitlab.rb
sed: impossible de lire ./etc.gitlab.rb.girofle: Aucun fichier ou dossier de ce type
cat: ./etc.gitlab.rb.girofle: Aucun fichier ou dossier de ce type
lstat /home/jibl/doc-pms/etc.gitlab.rb.girofle: no such file or directory
cp: cannot stat './etc.gitlab.rb.girofle': No such file or directory
conteneur-kytes.io.gitlab.1
d0024e1d7990969af10a964f662087930f8ac57a905d5611c38c4e302354b3d0
Error: No such container:path: conteneur-kytes.io.gitlab.2:/etc/gitlab/gitlab.rb
sed: impossible de lire ./etc.gitlab.rb.girofle: Aucun fichier ou dossier de ce type
cat: ./etc.gitlab.rb.girofle: Aucun fichier ou dossier de ce type
lstat /home/jibl/doc-pms/etc.gitlab.rb.girofle: no such file or directory
cp: cannot stat './etc.gitlab.rb.girofle': No such file or directory
conteneur-kytes.io.gitlab.2
```
=> tests inventory.girofle
=> tests restore/backup

# ANNEXE: Docker et CentOS

Au cours du développement de Girofle, j'ai pu constater, que le `NetworkManager` engendre des problèmes connus:
* Tout d'abord, que ce soit avec, ou sans le `NetworkManager`, effectuer une reconfiguration réseau *après* une installation Docker, peut sans aucun doute engendrer de nombreux problèmes, et ce, parce que Docker installe des bridges réseaux, et créée des "veth" par conteneurs.
* Comme vous pourrez le lire vous-même [dans la recommandation officielle Docker](https://success.docker.com/article/should-you-use-networkmanager), le Network Manager ralentira drastiquement l'exécution des conteneurs si le NetworkManager est en service dans l'hôte Docker. J'ia moi-même pu constater cette lenteur.
* Pour le cas où le lien vers [cette recommandation officielle Docker](https://success.docker.com/article/should-you-use-networkmanager), voici une impression écran de cette recommandation, au 02/04/2018:

![Recommandations Officelles Docker - Cent OS - NetworkManager](https://raw.githubusercontent.com/Jean-Baptiste-Lasselle/girofle/master/doc/recommandations-officielles-docker-rhel-network-manager.png "Recommandations Officelles Docker - Cent OS - NetworkManager")
