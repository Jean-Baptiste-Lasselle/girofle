# Docker sur centos 7


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							ENV								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# - Variables d'environnement héritées:
#                >>>   0
# --------------------------------------------------------------------------------------------------------------------------------------------
# - répertoires  dans l'hôte docker
# --------------------------------------------------------------------------------------------------------------------------------------------
export REP_GESTION_CONTENEURS_DOCKER=/girofle
# à remplacer par une petite bdd embarquée de type nosql, .h2, pour au moins avoir gestion des accès concconcurrents, et enfin à remplacer par [etcd]
export INVENTAIRE_GIROFLE=$REP_GESTION_CONTENEURS_DOCKER/inventory.girofle
# --------------------------------------------------------------------------------------------------------------------------------------------
# - instance Gitlab concernée
# --------------------------------------------------------------------------------------------------------------------------------------------
# cf. fonction demander_addrIP ()
export ADRESSE_IP_SRV_GITLAB
# Numéro d'instance Gitlab: Doit s'auto-incrémenter
# Pour implémenter l'uto-incrément, je vais utiliser une technique nulle: un
# fichier, dans lequel je rajoute une ligne à chaque fois que je créée une nouvelle instance gitlab, que je compte ensuite, etc...
export COMPTEUR_GIROFLE=$REP_GESTION_CONTENEURS_DOCKER/.auto-increment.girofle
export GITLAB_INSTANCE_NUMBER=1

demanderQuelleInstanceDecomissioner () {

	echo "Quelle est le numéro d'instance Gitlab que vous souhaitez restaurer?"
	echo "liste des insances en service:"
	echo " "
	./lister-instances-gitlab.sh
	echo " "
	read INSTANCE_CHOISIE
	if [ "x$INSTANCE_CHOISIE" = "x" ]; then
	   echo " +girofle+ERREUR+ impossible de déterminer le numéro d'instance à dé-comissioner."
       exit 1
	fi
	GITLAB_INSTANCE_NUMBER=$INSTANCE_CHOISIE
	echo " Binding Adresse IP choisit pour le serveur gitlab: $INSTANCE_CHOISIE";
}

# --------------------------------------------------------------------------------------------------------------------------------------------
#														RESEAU-HOTE-DOCKER																	 #
# --------------------------------------------------------------------------------------------------------------------------------------------
# [SEGMENT-IP alloués par DHCP bytes: 192.168.1.123 => 192.168.1.153]
# ADRESSE_IP_LINUX_NET_INTERFACE_1=192.168.1.123
# ADRESSE_IP_LINUX_NET_INTERFACE_2=192.168.1.124
# ADRESSE_IP_LINUX_NET_INTERFACE_3=192.168.1.125
# ADRESSE_IP_LINUX_NET_INTERFACE_4=192.168.1.126
# --------------------------------------------------------------------------------------------------------------------------------------------

#			MAPPING des répertoires d'installation de gitlab dans les conteneurs DOCKER, avec des répertoires de l'hôte DOCKER				 #
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
# ---------------------------------------
# - répertoires d'installation de gitlab
# ---------------------------------------
GITLAB_CONFIG_DIR=/etc/gitlab
GITLAB_DATA_DIR=/var/opt/gitlab
GITLAB_LOG_DIR=/var/log/gitlab

# intiialisation du numéro d'instance Gitlab à dé-comissioner
if [ "$1" = "x$1" ]; then
   demanderQuelleInstanceRestaurer
else
	GITLAB_INSTANCE_NUMBER=$1
fi


export NOM_CONTENEUR_DOCKER=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER

# répertoire dédié au conteneur géré dans cette suite d'opérations
export REP_GIROFLE_CONTENEUR_DOCKER=$REP_GESTION_CONTENEURS_DOCKER/noeud-gitlab-$GITLAB_INSTANCE_NUMBER

# - répertoires associés
CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR=$REP_GIROFLE_CONTENEUR_DOCKER/config
CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR=$REP_GIROFLE_CONTENEUR_DOCKER/data
CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR=$REP_GIROFLE_CONTENEUR_DOCKER/logs

export REP_BCKUP_CONTENEUR_DOCKER=$REP_GIROFLE_CONTENEUR_DOCKER/bckups
# le nom du répertoire (pas son chemin absolu) dans $REP_BCKUP_CONTENEUR_DOCKER
export REP_BCKUP


# export REP_BCKUP_COURANT=$REP_GESTION_CONTENEURS_DOCKER/bckups/$OPSTIMESTAMP

# rm -rf $REP_BCKUP_COURANT
# mkdir -p $REP_BCKUP_COURANT/log
# mkdir -p $REP_BCKUP_COURANT/data
# mkdir -p $REP_BCKUP_COURANT/config

# TODO => demander interactivement à l'utilisateur le nom du conteneur docker à backup/restore ### DOIT AUSSI DEVENIR VARIABLE D'ENVIRONNEMENT
# mais d'ailleurs, concrètement, c'est à ce point exact qu'est fait le lien entre les dépendances:
#           NOM_CONTENEUR_DOCKER <=> noms du répertoire [$REP_GIROFLE_CONTENEUR_DOCKER]
# Sachant que al règle implicite est que pour chaque service gitlab, un conteneur est créé avec un nom, et un répertoire lui
# est donné, [$REP_GIROFLE_CONTENEUR_DOCKER], dans lequel on a, pour chaque conteneurs, 5 sous répertoires en arbre:
# [$REP_GESTION_CONTENEURS_DOCKER]
#				| 
#				| 
# 		[$REP_GIROFLE_CONTENEUR_DOCKER]
# 											|
# 											|__ mapping-volumes
# 											|	   	  |__ data
# 											|	   	  |__ config
# 											|	   	  |__ log
# 											|
# 											|
# 											|__ bckups
# 											|	   |
# 											|	   |__ unedate/
# 											|	   |	  |__ data
# 											|	   |	  |__ config
# 											|	   |	  |__ log
# 											|	   |	  |
# 											|	   |	  |
# 											|	   |
# 											|	   |
# 											|	   |__ uneautredate/
# 											|	   |	  |__ data
# 											|	   |	  |__ config
# 											|	   |	  |__ log
# 											|	   |	  |
# 											|	   |	  |
# 											|	   |
# 											|	   |
# 											|	   
# 											|	      
#    
#    
#    


##############################################################################################################################################

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							FONCTIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------




# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							OPERATIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# - hostname:  archiveur-prj-pms.io

# 1./ Je backuppe l'instance, avant de la détruire:
./backup.sh $GITLAB_INSTANCE_NUMBER

# 2./ Je supprime l'occurence de l'instance dans le fichier d'inventaire [$INVENTAIRE_GIROFLE]
#    en filtrant les lignes du fihciers avec AWK et régénrer le fichier d'inventaire.
cat $INVENTAIRE_GIROFLE|awk  "/\[$GITLAB_INSTANCE_NUMBER\]/ { next; } {$1 = $1;print}" >> $INVENTAIRE_GIROFLE.nouveau
rm -f $INVENTAIRE_GIROFLE.nouveau
cp -f $INVENTAIRE_GIROFLE.nouveau $INVENTAIRE_GIROFLE

# données de test générées
# export INVENTAIRE_GIROFLE_TEST=./inventory.girofle
# rm -f $INVENTAIRE_GIROFLE_TEST
# export ENTREE_INVENTAIRE_TEST=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] + [REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST=$REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST] + [NOM_DU_CONTENEUR_CREE=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER]"

# test 1
# GITLAB_INSTANCE_NUMBER=1
# ADRESSE_IP_SRV_GITLAB="192.168.1.32"
# NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=15648
# NOM_DU_CONTENEUR_CREE=poulet
# ENTREE_INVENTAIRE_TEST=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] + [REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST=$REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST] + [NOM_DU_CONTENEUR_CREE=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER]"
# echo $ENTREE_INVENTAIRE_TEST >> $INVENTAIRE_GIROFLE_TEST
# test 2
# GITLAB_INSTANCE_NUMBER=2
# ADRESSE_IP_SRV_GITLAB="192.168.1.32"
# NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=54248
# NOM_DU_CONTENEUR_CREE=tricot
# ENTREE_INVENTAIRE_TEST=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] + [REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST=$REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST] + [NOM_DU_CONTENEUR_CREE=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER]"
# echo $ENTREE_INVENTAIRE_TEST >> $INVENTAIRE_GIROFLE_TEST
# test 3
# GITLAB_INSTANCE_NUMBER=5
# ADRESSE_IP_SRV_GITLAB="192.168.1.32"
# NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=7778
# NOM_DU_CONTENEUR_CREE=ahbon
# ENTREE_INVENTAIRE_TEST=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] + [REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST=$REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST] + [NOM_DU_CONTENEUR_CREE=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER]"
# ENTREE_INVENTAIRE_RECHERCHEE=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=([0-255].[0-255].[0-255].[0-255])] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=([0-65536])] + [REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST=(*)] + [NOM_DU_CONTENEUR_CREE=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER]"
# echo $ENTREE_INVENTAIRE_TEST >> $INVENTAIRE_GIROFLE_TEST
# test 4
# GITLAB_INSTANCE_NUMBER=4
# ADRESSE_IP_SRV_GITLAB="192.168.1.32"
# NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=2368
# NOM_DU_CONTENEUR_CREE=poulet
# ENTREE_INVENTAIRE_TEST=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] + [REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST=$REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST] + [NOM_DU_CONTENEUR_CREE=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER]"
# echo $ENTREE_INVENTAIRE_TEST >> $INVENTAIRE_GIROFLE_TEST

### ==>>> Et là, je peux faire le test de substitution
# echo "TEST -girofle+ DEBUT TEST"
# echo "TEST -girofle+ "
# echo "TEST -girofle+ "
# echo "TEST -girofle+ AVANT substitution dans l'inventaire:"
# echo "TEST -girofle+ "
# cat $INVENTAIRE_GIROFLE_TEST
# echo "TEST -girofle+ "
# sed -i "s/$ENTREE_INVENTAIRE_RECHERCHEE/-elforig-/g" $INVENTAIRE_GIROFLE_TEST
# echo "TEST -girofle+ "
# echo "TEST -girofle+ APRES substitution dans l'inventaire:"
# echo "TEST -girofle+ "
# cat $INVENTAIRE_GIROFLE_TEST
# echo "TEST -girofle+ "
# echo "TEST -girofle+ "
# echo "TEST -girofle+ FIN TEST"



# --------------------------------------------------------------------------------------------------------------------------------------------
# Installation de l'instance gitlab dans un conteneur, à partir de l'image officielle :
# https://docs.gitlab.com/omnibus/docker/README.html
# --------------------------------------------------------------------------------------------------------------------------------------------
# ce conteneur docker est lié à l'interface réseau d'adresse IP [$ADRESSE_IP_SRV_GITLAB]:
# ==>> Les ports ouverts avec loption --publish seront accessibles uniquement par cette adresse IP
#
# sudo docker run --detach --hostname gitlab.$GITLAB_INSTANCE_NUMBER.kytes.io --publish $ADRESSE_IP_SRV_GITLAB:4433:443 --publish $ADRESSE_IP_SRV_GITLAB:8080:80 --publish 2227:22 --name $NOM_CONTENEUR_DOCKER --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR:$GITLAB_DATA_DIR gitlab/gitlab-ce:latest
# Mais maintenant, j'utilise le nom d'hôte de l'OS, pour régler la question du nom de domaine ppour accéder à l'instance gitlab en mode Web.
# export NOMDHOTE=archiveur-prj-pms.io
sudo docker stop $NOM_CONTENEUR_DOCKER
sudo docker rm $NOM_CONTENEUR_DOCKER

##########################################################################################
#			configuration du nom de domaine pou l'accès à l'instance gitlab   		   	 #  
##########################################################################################
# ----------------------------------------------------------------------------------------
#  - 4 adresses IP dans la VM hôte docker.
# ----------------------------------------------------------------------------------------
# Dans l'hôte docker, on utilise "/etc/hosts" pour config. la résolution noms de domaines:
#
#  - Une des 4 adresses IP de la VM hôte Docker <=> HOSTNAME du conteneur docker/gitlab
#  - On pourra alors avoir jusqu'à 4 conteneurs Docker, accessibles depuis la
#	 VM hôte docker, par 4 noms de domaines différents, correspondant aux 4 hostnames
#	 utilisés pour créer les conteneurs (option --hostname).
# ----------------------------------------------------------------------------------------
# Contenu qui doit être ajouté dans le fichier "/etc/hosts"
# ----------------------------------------------------------------------------------------
# # -----------------------------
# # BYTES CI/CD 
# # -----------------------------
# # + kytes.iofactory jenkins-node
# jenkins.$JENKINS_INSTANCE_NUMBER.bytes.com $ADRESSE_IP_LINUX_NET_INTERFACE_1
# # + bytes.factory artifactory-node
# jenkins.$JENKINS_INSTANCE_NUMBER.bytes.com $ADRESSE_IP_LINUX_NET_INTERFACE_2
# # + bytes.factory gitlab-node ---------------------------------------------------------------------------- >> celui-là c'est le noeud gitlab
# gitlab.$GITLAB_INSTANCE_NUMBER.bytes.com $ADRESSE_IP_SRV_GITLAB
# ----------------------------------------------------------------------------------------


# éditer dans le conteneur docker, le fichier "/etc/gitlab/gitlab.rb":
# sudo docker exec -it gitlab vi /etc/gitlab/gitlab.rb
# et donner la valeur suivante au paramètre "external_url":
# external_url "http://gitlab.$GITLAB_INSTANCE_NUMBER.bytes.com:8080"
# autre exemple avec une valeur exemple d'url
# external_url "http://gitlab.example.com"



##########################################################################################
#				DOC OFFICELLE POUR CONFIG GITLAB DANS CONTENEUR DOCKER 					 #
##########################################################################################
# export AUTRE_OPTION= ce que vou voulez parmi els optiosn de config gitlab
# --env GITLAB_OMNIBUS_CONFIG="external_url 'http://my.domain.com/'; $AUTRE_OPTION;"
# Exemple valide:
# --env GITLAB_OMNIBUS_CONFIG="external_url 'http://my.domain.com/';"
##########################################################################################
# By adding the environment variable GITLAB_OMNIBUS_CONFIG to docker run command.
# This variable can contain any gitlab.rb setting and will be evaluated before loading
# the container's gitlab.rb file.
##########################################################################################
# HTTPS et GITLAB ==>> 
##########################################################################################
# 
# 
# 
# 
# 
# 


