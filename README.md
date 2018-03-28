# Girofle

Cette recette provisionne un pseudo système, qui à l'utilisation se réduits à utiliser des scripts tous situés dans le même répertoire.

J'ai accessoirement baptisé le pseudo-système "[Girofle](#)".

Ce pseudo système permet de créer autant de conteneurs [Gitlab](https://gitlab.io) qu'il y a d'interfaces réseau dans le système sous jacent (supporté pour l'instant: centos 7) 
dans la même VM, et de pouvoir pour chacun:
* comissioner une nouvelle instance gitlab, (en lui donnant éventuellement un nom, qui sera suffixé dans le nom du conteneur docker), et en retour on a l'url complète vers l'instace gitlab comissionnée.
* dé-commissioner une nouvelle instance gitlab (pas la détruire sauvagement).
* lister les instances gitlab
* pour une instance gitlab, faire un backup local
* pour une instance gitlab, faire un backup remote (vers un stockage qui peut être choisit)
* pour une instance gitlab, faire un restore dans une autre VM, ou la même VM
* pour une instance gitlab, à la comission, les backups locaux sont faits automatiquement (configurés comme une tâche réccurrente système crontab):

```
# 1./ il faut ajouter la ligne:
# 
# => pour une toutes les 4 heures: [* */4 * * * "$(pwd)/operations-std/serveur/backup.sh"]
#  
# Au fichier crontab:
# 
# Mode manuel: sudo crontab -e
# Mode silencieux:
export PLANIFICATION_DES_BCKUPS="* */4 * * *   $(pwd)/operations-std/serveur/backup.sh"
rm -f ./operations-std/serveur/bckup.kytes
echo "$PLANIFICATION_DES_BCKUPS" >> ./operations-std/serveur/bckup.kytes
crontab ./operations-std/serveur/bckup.kytes
rm -f ./operations-std/serveur/bckup.kytes
echo " provision-girofle- Le backup Girafle a été cofniguré pour  " >> $NOMFICHIERLOG
echo " provision-girofle- s'exécuter automatiquent de la manière suivante: " >> $NOMFICHIERLOG
echo " provision-girofle-  " >> $NOMFICHIERLOG
crontab -l >> $NOMFICHIERLOG
echo " provision-girofle-  TERMINEE - " >> $NOMFICHIERLOG
#    ANNEXE crontab quickies
# => pour une fois par nuit: [* 1 * * * "$(pwd)/operations-std/serveur/backup.sh"]
# => pour une toutes les 2 heures: [* */2 * * * "$(pwd)/operations-std/serveur/backup.sh"]
# => pour une toutes les 4 heures: [* */4 * * * "$(pwd)/operations-std/serveur/backup.sh"]
# => pour une fois par nuit: [*/5 */1 * * * "$(pwd)/operations-std/serveur/backup.sh"]
# => Toutes les 15 minutes après 7 heures: [5 7 * * * "$(pwd)/operations-std/serveur/backup.sh" ]

```

<!-- # 2./ il faut redémarrer le système? (me souvient plus...) --> 

# stdopsbckups

* client:
  * save local
  * push remote if there are more local commits  than remote
  * resolve conflicts if there are more remote commits than local, with:
    * copy versioned directory to another, as backup
    * clone the remote
    * automatically present list of files missing or presenting differences
	* automatically add missing files
	* which will leave only a list of files with differences to remote
* server:
  * bakup gitlab data, config & log dir
  * restore instance
  * wikis not included, README.md versioned with source code
  
  
* launching ops

```
# mkdir doc-pms && cd doc-pms && git clone "" . && sudo chmod +x ./operations.sh && ./operations.sh
# mkdir doc-pms && cd doc-pms && git clone "https://github.com/Jean-Baptiste-Lasselle/girofle" . && sudo chmod +x ./operations.sh && ./operations.sh

```

# TODOs

## 1. Sur les opérations de backup/restore

* Future règle à implémenter:
```
# La règle implicite est que pour chaque service gitlab, un conteneur est créé avec un nom, et un répertoire lui
# est donné : [$REP_GESTION_CONTENEURS_DOCKER/noeud-gitlab-$GITLAB_INSTANCE_NUMBER].
# Dans lequel ce répertoire on a, pour chaque conteneur, 5 sous répertoires en arbre:
# [$REP_GESTION_CONTENEURS_DOCKER]
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
#    => les bckups devront être stockés dans [$REP_GESTION_CONTENEURS_DOCKER/noeud-gitlab-$GITLAB_INSTANCE_NUMBER/bckups]
#    

```

* Dépendances entre variables d'env.

Le fichier `./operations-std/serveur/restore.sh`, est pour le moment le point exact où est faite l'association entre: 

```
 $NOM_CONTENEUR_DOCKER <=> $REP_GIROFLE_CONTENEUR_DOCKER
```
`$REP_GIROFLE_CONTENEUR_DOCKER` étant le nom du répertoire dédié au conteneur $NOM_CONTENEUR_DOCKER, exemple: 

```
export REP_GIROFLE_CONTENEUR_DOCKER=$REP_GESTION_CONTENEURS_DOCKER/noeud-gitlab-$GITLAB_INSTANCE_NUMBER
```

Globalement les opérations standard utilisent donc 3 variables indépendantes:

```
 $NOM_CONTENEUR_DOCKER <=> $REP_GIROFLE_CONTENEUR_DOCKER <=> $ADRESSE_IP_DEDIEE_AU_SERVICE_GITLAB
```

Et la donnée de la valeur de ces 3 variables est suffisante à Girofle pour déduire toute autre information à propos d'une instance répertoirée dans le fichier:

```
	export INVENTAIRE_GIROFLE=$REP_GESTION_CONTENEURS_DOCKER/inventory.girofle
```

Dans `./operations-std/serveur/restore.sh`, c'est la variable d'environnement `$ADRESSE_IP_SRV_GITLAB` qui correspond à `$ADRESSE_IP_DEDIEE_AU_SERVICE_GITLAB`



* À implémenter:

Demander interactivement à l'utilisateur le nom du conteneur docker à backup/restore, ainsi que le chemin de son répertoire dédié

De la sorte, l'association est déléguée intractivement ou avec arguments en ligne de commande:

* si aucun argument n'est passé à `./operations-std/serveur/restore.sh`, il demande interactivement le nom du conteneur docker, et le chemin de son répertoire dédié (exemple: [`$REP_GESTION_CONTENEURS_DOCKER/noeud-gitlab-$GITLAB_INSTANCE_NUMBER`])
* si un seul argument est passé, alors un message d'erreur est affiché, et l'aide affichée.
* si deux arguments sont passés, alors:
  * le premier est considéré comme étant le nom du conteneur docker (et alors s'il la commande `docker ps -a` ne renvoie pas une sortie standard contenant le nom du conteneur, une erreur est levée)
  * le second est considéré comme étant le chemin du répertoire dédié du conteneur docker, et alors une erreur est levée si les conditions suivnates ne sont pas vérifiées:
    *  le répertoire indiqué existe dans le système,
    *  le répertoire indiqué contient un répertoire de nom "mapping-volumes", qui doit contenir aussi 3 répertoires "data", "config", "log", 
    *  le répertoire indiqué contient un répertoire de nom "bckups", qui doit contenir au moins un répertoire (un backup), qui lui-même doit contenir aussi 3 répertoires "data", "config", "log"

* faire la création:
  * d'un utilisateur linux qui effectue le provisioning de girofle
  * d'un utilisateur linux qui sera utilisé pour exécuter girofle

* faire un conteneur docker dans lequel je mettrai le git pour faire tout ce qu'il y a à faire avec git. De cette manière, plus de git installé sur l'hôte, le conteneur de comissioning ainsi utilisé est détruit à la fin du commissioning, ne laissant que les logs des opérations. Ce qui permet au passage de ne pas créer d'utilisateur dédié au comissioning sur la machine hôte.

# `gravity`

Girofle permettra de créer des multivers de galaxies Git.

Aux fonctionnalitrés [citées ci-dessus](#girofle), s'ajouteront celles du composant "`gravity`". "`gravity`" permettra:
* de construire un ensemble de repo git, les configurer (provision)
* d'exécuter une suite d'actions sur cet ensemblede repo git: Cet ensemble d'action est un test automatisé d'un "bout" de workflow.
"`gravity`" Permet donc de développer des workflows, et produira en sortie un fichier BPMN 2.0 exécutable, pour s'intégrer à [Kytes](https://github.com/Jean-Baptiste-Lasselle/kytes)

# POINT DE REPRISE

L'erreur surlaquelle je tombe est avec la dernière verson est:
```
./operations.sh: ligne57: ./docker-EASE-SPACE-BARE-METAL-SETUP.sh: Permission non accordée
```

# MSCs

Il faudra remplacer `$INVENTAIRE_GIROFLE` par une BDD NoSQL pour régler le problème d'accès concurrent, puis par /etcd