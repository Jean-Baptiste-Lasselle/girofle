# Girofle

Cette recette provisionne un pseudo système, qui à l'utilisation se réduit à utiliser des scripts tous situés dans le même répertoire.

J'ai accessoirement baptisé le pseudo-système "[Girofle](#)".

Une fois installé, Girofle permet de créer autant de conteneurs [Gitlab](https://gitlab.io) qu'il y a d'interfaces réseau dans le système sous jacent 
dans la même VM, et de pouvoir pour chacun:
* Comissioner une nouvelle instance gitlab, (en lui donnant éventuellement un nom, qui sera suffixé dans le nom du conteneur docker), et en retour on a l'url complète vers l'instance Gitlab comissionnée.
* Dé-commissioner une instance gitlab (pas la détruire sauvagement).
* Lister les instances gitlab
* Pour une instance gitlab, faire un backup local
* Pour une instance gitlab, faire un backup remote (vers un stockage qui peut être choisit)
* Pour une instance gitlab, faire un restore dans une autre VM, ou la même VM
* Pour une instance gitlab, à la comission, les backups locaux sont faits automatiquement (configurés comme une tâche réccurrente système crontab):

Girofle est testé pour les OS suivant:
* CentOS 7

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
  



# TODOs

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
  
### Utilsiateurs Linux provision Girofle

Modifier le provisionning Girofle, pour que le processus d'installation:
* créée un utilisateur linux qui effectue le provisioning de Girofle
* créée un utilisateur linux qui sera utilisé pour exécuter Girofle

### Conteneur Docker `girofle-provisioner`

Modifier le provisionning Girofle, pour que le processus d'installation se fasse à l'itérieur d'un conteneur Docker, dans 
lequel est fait tout ce qu'il y a à faire avec git. De cette manière, plus de git installé sur l'hôte, le conteneur de comissionning ainsi utilisé est 
détruit à la fin du commissioning, ne laissant que les logs des opérations. Ce qui permet au passage de ne pas créer d'utilisateur dédié au 
comissioning sur la machine hôte.

### Il faudra remplacer `$INVENTAIRE_GIROFLE` par une BDD NoSQL pour régler le problème d'accès concurrent, puis par /etcd


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
./installation-docker-gitlab.rectte-jibl.sh: ligne192:  +girofle+ INSTANCE GITLAB no. [1] + [ADRESSE_IP_SRV_GITLAB= ] +[NO_PORT_IP_SRV_GITLAB=80] + [REP_GIROFLE_INSTANCE_GITLAB=/girofle/noeud-gitlab-1] + [NOM_DU_CONTENEUR_CREE=conteneur-kytes.io.gitlab.1]: Aucun fichier ou dossier de ce type
docker: Invalid ip address  : address  :: unexpected '[' in address.
See 'docker run --help'.
./installation-docker-gitlab.rectte-jibl.sh: ligne214:  +girofle+ INSTANCE GITLAB no. [1] + [ADRESSE_IP_SRV_GITLAB= ] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=] + [REP_GIROFLE_INSTANCE_GITLAB_SUPPLEMENTAIRE_POUR_TEST=/girofle/noeud-gitlab-2] + [NOM_DU_CONTENEUR_CREE=conteneur-kytes.io.gitlab.1]: Aucun fichier ou dossier de ce type
```
=> tests inventory.girofle
=> tests restore/backup

# ANNEXE: Docker et CentOS

Au cours du développement de Girofle, j'ai pu constater, que le `NetworkManager` engendre des problèmes connus:
* Tout d'abord, que ce soit avec, ou sans le `NetworkManager`, effectuer une reconfiguration réseau *après* une installation Docker, peutsans aucun doute engendrer de nombreux problèmes, et ce, parce que Docker installe des bridges réseaux, et créée des "veth" par conteneurs.
* Comme vous pourrez le lire vous-même [dans la recommandation officielle Docker](https://success.docker.com/article/should-you-use-networkmanager), le Network Manager ralentira drastiquement l'exécution des conteneurs si le NetworkManager est en service dans l'hôte Docker. J'ia moi-même pu constater cette lenteur.
* Pour le cas où le lien vers [cette recommandation officielle Docker](https://success.docker.com/article/should-you-use-networkmanager), voici une impression écran de cette recommandation, au 02/04/2018:

![Recommandations Officelles Docker - Cent OS - NetworkManager](https://raw.githubusercontent.com/Jean-Baptiste-Lasselle/girofle/master/doc/recommandations-officielles-docker-rhel-network-manager.png "Recommandations Officelles Docker - Cent OS - NetworkManager")

