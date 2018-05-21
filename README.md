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

## Image docker avec CHEKCKHEALTH custom

Dans le dockerfile qui me permet de construire ma propre image docker de gitlab, je dois pouvoir paramétrer à l'exécution le nom de domaine et le numéor de port de l'instance:

```
# ===>>>> IL FAUT PERMETTRE DE RENDRE CONFIGURABLE A L'EXECUTION CES PARAMETRES DU GENRE [docker run .... -e NOMDEDOMAINE_INSTANCE_GITLAB=sopra.cardiff.scm -e NO_PORT_IP_SRV_GITLAB=8880]
echo "HEALTHCHECK --interval=1s --timeout=300s --start-period=1s --retries=300 CMD curl --fail http://$ADRESSE_IP_SRV_GITLAB:$NO_PORT_IP_SRV_GITLAB/ || exit 1" >> $DOCKERFILE_INSTANCES_GITLAB
```

De mémoire, je crois que j'ai utilisé la technique pour faire mes dockerfile `gogs.io`


## TODO: ops std

* Utiliser [ce nouveau repo](https://github.com/Jean-Baptiste-Lasselle/recette-conditionnment-java-windows) pour créer les repository nécesséaires au déploiement du client Girofle.
* Il faut isntaller les scripts d'opérations standards dans le répertoire `/girofle/operations-std`
* re-tester les backup automatiques.



## TODO: Sécurisation


### authentification OAuth2/SAML

Mettre en oeuvre l'authentification "SAML"](https://docs.gitlab.com/ee/integration/saml.html) pour chaque instance Gitlab, et vérifer les CRUD sur auth et autorisations.


Le script [`configuration-authentification-autorisations.sh`], configure authentification et autorisations SAML / OAuth2 , avec 
l'intégration au serveur OAuth2 précisé dans la configuration Girofle, ou le serveur OAuth2 provisionné avec Girofle, si aucun n'est 
précisé dans la configuration de (la provision) Girofle.


### authentification TLS / PKI

Type de menace parée: éviter à l'utilisateur de se faire sniffer ses mots de passe Girofle sur le réseau interne, quelque soit l'attaquant.


Mettre en oeuvre la provision de l'instance Gitlab, en lui fournissant un certificat Let's Encrypt, là où Let's Encrypt est intégré au 
serveur d'identité / enrôlement [Free IPA Server](#)

De plus, je dois fournir une documentation d'intégration de l'instance Let's Encrypt dans une PKI (obtenir un certificat de la part d'une Autorité Racine, ce qui 
suffit à propager l'identité dans la PKI)



```

# Reste à appliquer les instructions de :
# - https://docs.gitlab.com/ee/integration/saml.html  , qui a comme pré-requis:
#   +  https://docs.gitlab.com/ee/install/installation.html#using-https
# - et au cours de cette docuementation, il faudra exécuter aussi:
#   +  https://docs.gitlab.com/ee/integration/omniauth.html#initial-omniauth-configuration
# - et pour configurer un OAuth2 provider server, de mon choix: https://docs.gitlab.com/ee/integration/omniauth.html#configure-omniauth-providers-as-external
#   + exemple dans le fichier "gitlab.yml": 
# --------------------------------------------------------------
#  omniauth:
#    external_providers: ['twitter', 'google_oauth2'] 
# --------------------------------------------------------------
# L'idée serait d'utiliser mon propre serveur OAuth2 / SAML, déployé indépendamment et Free-Ipa-Server gère l'identité de l'ensemble Serveur OAuth2 / Girofle.
# ---
# Intégrer la provision d'éclipse dans une VM, et à la provision, toutes les authentifications fonctionnent
# --- 
# Le client Girofle en java, "pour l'utilisateur non-IT", devra s'authentifier lui aussi en SAML, avec JGit / JSch
# 
```


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
* créée un utilisateur linux qui sera utilisé pour administrer Girofle

### Conteneur Docker `girofle-provisioner`

Modifier le provisionning Girofle, pour que le processus de provision se fasse à l'intérieur d'un conteneur Docker, dans 
lequel est fait tout ce qu'il y a à faire avec git. De cette manière, plus de git installé sur l'hôte, le conteneur de comissionning ainsi utilisé est 
détruit à la fin du commissioning, ne laissant que les logs des opérations.

### Persistance inventaire

Il faudra remplacer `$INVENTAIRE_GIROFLE` par une BDD NoSQL pour régler le problème d'accès concurrent, plus essai avec `/etcd` et `infinispan`

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

=> tests inventory.girofle
=> tests restore/backup

# ANNEXE: Docker et CentOS

Au cours du développement de Girofle, j'ai pu constater, que le `NetworkManager` engendre des problèmes connus:
* Tout d'abord, que ce soit avec, ou sans le `NetworkManager`, effectuer une reconfiguration réseau *après* une installation Docker, peut sans aucun doute engendrer de nombreux problèmes, et ce, parce que Docker installe des bridges réseaux, et créée des "veth" par conteneurs.
* Comme vous pourrez le lire vous-même [dans la recommandation officielle Docker](https://success.docker.com/article/should-you-use-networkmanager), le Network Manager ralentira drastiquement l'exécution des conteneurs si le NetworkManager est en service dans l'hôte Docker. J'ia moi-même pu constater cette lenteur.
* Pour le cas où le lien vers [cette recommandation officielle Docker](https://success.docker.com/article/should-you-use-networkmanager), voici une impression écran de cette recommandation, au 02/04/2018:

![Recommandations Officelles Docker - Cent OS - NetworkManager](https://raw.githubusercontent.com/Jean-Baptiste-Lasselle/girofle/master/doc/recommandations-officielles-docker-rhel-network-manager.png "Recommandations Officelles Docker - Cent OS - NetworkManager")

  
# ANNEXE: Pipelines Kytes

* un robot est constitué de 2 éléments:
  * d' un repo Git 
  * et d'un conteneur exécutant un build, avec un gitlab-runner déjà provisionné dedans, et connecté au serveur maître Gitlab, `HEALTH_CHECK` spécifique Kytes à à développer). À la place du gitlab runner, je peux aussi utiliser, dans le dockerfile de mon worker, une définition `CMD`de commande de démarrage du conteneur, qui permet de définir un build. Si ce build déclenché dans le conteneur est écrit en language de script, les buidls deveinnent dépendants de l'OS exécutant le buid. C'est peu gênant étant donné la facilité avec laquelle on change la distribution Linux dans un conteneur docker. Ceci étant, idéalement, il faudrait utiliser des recettes Ansible et Chef.io pour déclencher les builds... là où la question est intéresante, c'est que Ansible et Chef.io ne sont pas en soit pensés comme des orchestrateurs de pipeline, et il y aurait peut-être à faire quelque chose là, pour utilsier un language agnostique...
* un robot exécute un build, commit et pousse sur le repository git utilisé par l'exécution du pipeline. À chaque push d'un conteneur-gitlab-runner, les ficheirs générés modifiés etc... sont ajoutés et poussés aussi, pour être présents au git clone suivant. Le repository d'exécution du pipeline devient donc une sorte de pilier central autour duquel "tournent" des conteneurs dockers sorte de "workers" du pipeline. La dernière version du repository d'exécution du pipeline, est le package déployé dans la cible de déploiement
* À chaque exécution d'un pipeline, correspond donc un nouveau repository git complètemejnt neuf. Ce repossitory permet éventuellement de reprendre les oéprations là où elles s'étaient arrêtées parce que l'usine trop encombrée, ou a cessé de fonctionner anormalement.
* Si je peux re-définir l'action exécutée lorsque l'évènement push sur un repo est déclenché (WEBHOOK, possibles avec [gogs.io](#) aussi), et le re-définir de manière à transmettre sur une queue, pour que l'opération soit reprise sur échec et exécutée en atteneant le temps nécessaire, que l'usine baisse de régime. Donc du message Anynchrone
* faire des pipelines qui aient des exécutions paralèlles, donc ça donnerait un push qui déclenche deux gitlab-runner dans deux conteneurs séparés, ou deux services kubernetes.
* voilà comment créer des repository git avec l'API REST Gitlab:
Dixit [cette page](https://docs.gitlab.com/ce/api/projects.html#create-project) :
```

# curl --header "Private-Token: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v4/projects
# 
curl --header "PRIVATE-TOKEN: is2sP8rMFUPXrWAsvy7b" -X POST "https://gitlab.com/api/v3/projects?name=kytes-pipeline-worker-1&issues_enabled=false"

```

[exemple d'appel de l'API qui fonctionne avec simple token]:

![exemple d'appel de l'API qui fonctionne avec simple token](https://github.com/Jean-Baptiste-Lasselle/girofle/raw/master/doc/invocation-API-REST-GITLAB-creation-token-sur-instance-gitlab.png):

[le token est généré ainsi]:

![le token est généré ainsi](https://github.com/Jean-Baptiste-Lasselle/girofle/raw/master/doc/invocation-API-REST-GITLAB.png)

Dans ce cas, il suffit de savoir générer, avec l'API, des tokens pour utiliser l'API, qui sont distribués aux
pipelines pour chaque exécution, avec révocations à poteriori.




# ANNEXE: noms de domaines pour l'accès aux repositories

Utiliser Traefik.io , avec le backend docker:
https://docs.traefik.io/configuration/backends/docker/

je fais les sous domaines (tous correspondent à des conteneurs de l'infrastructure d'un pipe):
* Pool de repos de référence du code source de chaque composant applicatif
  - $ID_DU_PROJET.application.scm.nom-specifique-instance-gitlab4.kytes.io =>> 1 nom de domaine des repository de versionning du code source de l'application.
  - $ID_DU_PROJET.application.scm.nom-specifique-instance-gitlab5.kytes.io =>> 1 nom de domaine des repository de versionning du code source de l'application.
  - les repository de versionning du code source de l'application ne peuvent être ni supprimés, ni modifiés par le pipeline, qui n'a droit qu'en lecture, à ceux ci. Plusieurs pipeline peuvent utiliser le même repo de code source d'application. Ces repo sont uniques.
* Pool de repos pour les pipelines:  
  - $ID_DU_PROJET.$ID_DU_PIPELINE.scm.nom-specifique-instance-gitlab1.kytes.io
  - $ID_DU_PROJET.$ID_DU_PIPELINE.scm.nom-specifique-instance-gitlab2.kytes.io
  - $ID_DU_PROJET.$ID_DU_PIPELINE.scm.nom-specifique-instance-gitlab3.kytes.io
  - $ID_DU_PROJET.$ID_DU_PIPELINE.scm.nom-specifique-instance-gitlab6.kytes.io
  - $ID_DU_PROJET.$ID_DU_PIPELINE.scm.nom-specifique-instance-gitlab7.kytes.io ==>> Le dernier du pipeline donne la trace des déploiements de tous les pipeplines, par user, etc... rporting données à collecter de ce côité du tuyau.
* Pool de conenteneur exécutant les builds:
  - $ID_DU_PROJET.$ID_DU_PIPELINE.build.nom-specifique-conteneur-exécutant-un-build-1.kytes.io
  - $ID_DU_PROJET.$ID_DU_PIPELINE.build.nom-specifique-conteneur-exécutant-un-build-2.kytes.io
  - $ID_DU_PROJET.$ID_DU_PIPELINE.build.nom-specifique-conteneur-exécutant-un-build-3.kytes.io
  - $ID_DU_PROJET.$ID_DU_PIPELINE.build.nom-specifique-conteneur-exécutant-un-build-4.kytes.io
  - $ID_DU_PROJET.$ID_DU_PIPELINE.build.nom-specifique-conteneur-exécutant-un-build-5.kytes.io



## Sur [Traefik.io](https://traefik.io)

<!--
Il s'agit bien d'infrastructure:

![Les premiers mots qui sautent aux yeux](#)

--!>

[La documentation](https://docs.traefik.io/) indique:

* Il faut un `docker-compose.yml` contenant:

```
version: '3'

services:
  reverse-proxy:
    image: traefik #The official Traefik docker image
    command: --api --docker # Enables the web UI and tells Træfik to listen to docker
    ports:
      - "80:80"     #The HTTP port
      - "8080:8080" #The Web UI (enabled by --api)
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock # So that Traefik can listen to the Docker events

```
* puis exécuter:
 
```
docker-compose up -d reverse-proxy
# You can open a browser and go to http://localhost:8080 to see Træfik's dashboard

```
 
* Ensuite ajouter le contenu suivant, au fichier `docker-compose.yml`:
```
# ... À ajouter en fin de fichier
export NOM_DU_SERVICE
NOM_DU_SERVICE=whoami
export DOCKER_COMPOSE_YML=./docker-compose.yml
echo "whoami:" >> $DOCKER_COMPOSE_YML
echo "  image: emilevauge/whoami #A container that exposes an API to show it's IP address" >> $DOCKER_COMPOSE_YML
echo "  labels:" >> $DOCKER_COMPOSE_YML
echo "    - \"traefik.frontend.rule=Host:whoami.docker.localhost\"" >> $DOCKER_COMPOSE_YML
```
* Puis on exécute le nouveau docker compose:

```
export NOM_DU_SERVICE
NOM_DU_SERVICE=whoami
docker-compose up -d $NOM_DU_SERVICE
```
* Et on peut tester le nouveau service avec la commande:
```
curl -H Host:whoami.docker.localhost http://127.0.0.1
# permettra de mettre au point un HEALTH_CHECK spécifique Girofle:
# (healcheck spécifique à la platefome, pour la provision d'une nouvelle instance gitlab girofle) 
```


# ANNEXE Système Linux et NTP

Tout système Linux utilise son package manager qui permet d'installer des logiciels et autres packages.
Tous ces packages managers utilisent l'authentification serveur par le protocole SSL/TLS, avec certifcats.

Lorsque je créée des VMs Linux, bien souvent j'en fais des "snapshots" pour pouvoir revenir dans un état particulier (pour tests).
À chaque fosi que je restaure cet état, l'heure système reste inchangée.
Aussi, si je conserve un snapshot assez longtemps, le décalage entre la date des certificats SSL des repos linux, et la date de ma VM dans son état restauré, est 
si grand que le certificat devient inacceptable par le package manager, et toute installation devient impossible, y compris l'installation des utilitaires qui 
permettrraitent de rétablir l'heure et la synchronisation à un serveur NTP.

D'ailleurs, le cas se présente dans tous les cas où, pour une quelconque raison,  l'on "fait revenir dans le passé", l'horloge d'une instance d'OS.

Une solution dans ce cas:
Modifier le fichier `/etc/yum.conf`, pour lui ajouter en dernière ligne, la ligne:
```
sslverify=false 
``` 
Puis installer l'utilitaire qui pemettra de faire la mise à jour de l'heure système par synchroinistation sur un serveur NTP public:
```
sudo yum install -y ntp ntpdate

# vérfication des chemins d'installation:
sudo which ntp
sudo which ntpdate
```
Enfin, synchroniser le système sur un serveur NTP public bien connu:
```
export NOMFICHIERLOG=sys-datetime-mgmt-ops.log
sudo ntpdate 0.us.pool.ntp.org
echo "date après la re-synchronisation [Serveur NTP=$SERVEUR_NTP :]" >> $NOMFICHIERLOG
date >> $NOMFICHIERLOG
# pour re-synchroniser l'horloge matérielle, et ainsi conserver l'heure après un reboot, et ce y compris après et pendant
# une coupure réseau
sudo hwclock --systohc
```

Enfin il ne fait surtout pas ouiblier de retirer la ligne :
```
sslverify=false 
``` 
Du fichier `/etc/yum.conf`, AVANT toute autre opération.
Si cette réparation désespérée est faite en production, il serait sage de se polacer derrière un pare-feu voir s'isoler complètmeent dans un réseau avec l'univers de repos linux et un serveur NTP à l'heure, et privé.

## Morale 
Et la morale de l'histoire, c'est qu'il fauit TOUJOURS provisionner un serveur destiné à l'exploitation, avec son package d'utilitaires de gestion de l'heure système en synchronisation avec un serveur NTP.
Sinon on a toujours un danger de se retrouver avec un système dont la date est altérée vers le passé, et les packages managers intulisables.
