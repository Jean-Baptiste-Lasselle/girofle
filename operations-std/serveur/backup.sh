# Docker sur centos 7


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							ENV								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# - Variables d'environnement héritées:
#                >>>   0
# --------------------------------------------------------------------------------------------------------------------------------------------




# --------------------------------------------------------------------------------------------------------------------------------------------
#														RESEAU-HOTE-DOCKER																	 #
# --------------------------------------------------------------------------------------------------------------------------------------------
# [SEGMENT-IP alloués par DHCP bytes: 192.168.1.123 => 192.168.1.153]
# ADRESSE_IP_LINUX_NET_INTERFACE_1=192.168.1.123
# ADRESSE_IP_LINUX_NET_INTERFACE_2=192.168.1.124
# ADRESSE_IP_LINUX_NET_INTERFACE_3=192.168.1.125
# ADRESSE_IP_LINUX_NET_INTERFACE_4=192.168.1.126

export OPSTIMESTAMP=`date +"%d-%m-%Y-time-%Hh-%Mm-%Ss"`
# ---------------------------------------
# - répertoires  dans l'hôte docker
# ---------------------------------------

export REPERTOIRE_GIROFLE=/girofle
export NOMFICHIERLOG
export GITLAB_INSTANCE_NUMBER
REPERTOIRE_GIROFLE=/girofle
NOMFICHIERLOG=$REPERTOIRE_GIROFLE/girofle.log
# devra pouvoir servir pour avoir un serice de niommage par défaut des instances gitlab, et assurer l'intégrité/unicité du nommage des isntances.
GITLAB_INSTANCE_NUMBER=1
# ---------------------------------------
# - répertoires d'installation de gitlab
# ---------------------------------------
GITLAB_CONFIG_DIR=/etc/gitlab
GITLAB_DATA_DIR=/var/opt/gitlab
GITLAB_LOG_DIR=/var/log/gitlab

# Intialisation du numéro d'instance Gitlab à restaurer
if [ "$1" = "x$1" ]; then
   demanderQuelleInstanceRestaurer
else
	GITLAB_INSTANCE_NUMBER=$1
fi

# ---------------------------------------
# - répertoires Girofle
# ---------------------------------------
# - répertoire dédié au conteneur géré dans cette suite d'opérations
# cf. demander_rep_girofle_instance_gitlab ()
export REP_GIROFLE_CONTENEUR_DOCKER
# export REP_GIROFLE_CONTENEUR_DOCKER
# - répertoire dédié au backups du conteneur géré dans cette suite d'opérations
export REP_BCKUP_CONTENEUR_DOCKER
# - répertoire qui sera utilisé pour le backup en cours du conteneur géré dans cette suite d'opérations
export REP_BCKUP_COURANT

# --------------------------------------------------------------------------------------------------------------------------------------------
#			MAPPING des répertoires d'installation de gitlab dans les conteneurs DOCKER, avec des répertoires de l'hôte DOCKER				 #
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
# - répertoires associés
# CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR=$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER/config
# CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR=$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER/data
# CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR=$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER/logs

# - création des répertoires associés
# sudo rm -rf $REPERTOIRE_GIROFLE
# sudo mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR
# sudo mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR
# sudo mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR
##############################################################################################################################################

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							FONCTIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------

# afin de demander interactivement à l'utilisatuer, d'indiquer le répertoire dédié au conteneur de l'isntance Gitlab.
demander_rep_girofle_instance_gitlab () {

	echo " [-------------------------------------------------------------------] "
	echo " [-------------------------------------------------------------------] "
	echo "Dans le répertoire [$REPERTOIRE_GIROFLE], Quel est le "
	echo "nom du répertoire Girofle de l'instance Gitlab que vous souhaitez backupper?"
	echo " "
	echo " [-------------------------------------------------------------------] "
	echo "C'est l'un des suivants:"
	echo " "
	ls -all $REPERTOIRE_GIROFLE
	echo " "
	echo " [-------------------------------------------------------------------] "
	echo " Par défaut, le répertoire girofle choisi sera:"
	echo " "
	echo " [$REPERTOIRE_GIROFLE/noeud-gitlab-1]"
	echo " "
	echo " [-------------------------------------------------------------------] "
	echo " "
	echo " Son contenu:"
	echo " "
	ls -all $REPERTOIRE_GIROFLE/noeud-gitlab-1
	echo " "
	echo " [-------------------------------------------------------------------] "
	echo " [-------------------------------------------------------------------] "
	read REP_GIROFLE_INDIQUE
	if [ "x$REP_GIROFLE_INDIQUE" = "x" ]; then
       # REP_GIROFLE_INDIQUE=$(ls -t $REPERTOIRE_GIROFLE | head -1)
       REP_GIROFLE_INDIQUE=$REPERTOIRE_GIROFLE/noeud-gitlab-1
	fi
	
	REP_GIROFLE_CONTENEUR_DOCKER=$REP_GIROFLE_INDIQUE
	echo " le répertoire de backup qui sera utilisé pour ce backup est: $REP_GIROFLE_INDIQUE/$REP_BCKUP";
}

# - hostname:  archiveur-prj-pms.io


# --------------------------------------------------------------------------------------------------------------------------------------------
# Installation de l'instance gitlab dans un conteneur, à partir de l'image officielle :
# https://docs.gitlab.com/omnibus/docker/README.html
# --------------------------------------------------------------------------------------------------------------------------------------------
# ce conteneur docker est lié à l'interface réseau d'adresse IP [$ADRESSE_IP_SRV_GITLAB]:
# ==>> Les ports ouverts avec loption --publish seront accessibles uniquement par cette adresse IP
#
# sudo docker run --detach --hostname gitlab.$GITLAB_INSTANCE_NUMBER.kytes.io --publish $ADRESSE_IP_SRV_GITLAB:4433:443 --publish $ADRESSE_IP_SRV_GITLAB:8080:80 --publish 2227:22 --name conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR:$GITLAB_DATA_DIR gitlab/gitlab-ce:latest
# Mais maintenant, j'utilise le nom d'hôte de l'OS, pour régler la question du nom de domaine ppour accéder à l'instance gitlab en mode Web.
# export NOMDHOTE=archiveur-prj-pms.io
# sudo docker run --detach --hostname $HOSTNAME --publish $ADRESSE_IP_SRV_GITLAB:433:443 --publish $ADRESSE_IP_SRV_GITLAB:80:80 --publish 2227:22 --name conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR:$GITLAB_DATA_DIR gitlab/gitlab-ce:latest

demanderQuelleInstanceRestaurer () {

	echo "Quelle est le numéro d'instance Gitlab que vous souhaitez restaurer?"
	echo "liste des insances en service:"
	echo " "
	./lister-instances-gitlab.sh
	echo " "
	read INSTANCE_CHOISIE
	if [ "x$INSTANCE_CHOISIE" = "x" ]; then
	   echo " +girofle+ERREUR+ impossible de déterminer le numéro d'instance à backupper."
       exit 1
	fi
	GITLAB_INSTANCE_NUMBER=$INSTANCE_CHOISIE
	echo " Binding Adresse IP choisit pour le serveur gitlab: $INSTANCE_CHOISIE";
}

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							OPERATIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
#

# On commence par déterminer quel est l'instance à backupper
demander_rep_girofle_instance_gitlab
# La valeur de [$REP_GIROFLE_CONTENEUR_DOCKER] a été fixée par l'utilisateur de ce script
# et la valeur de [$REP_GIROFLE_CONTENEUR_DOCKER] définit la valeur de 5 autres vairables d'environnement d'exécution.
CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR=$REP_GIROFLE_CONTENEUR_DOCKER/config
CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR=$REP_GIROFLE_CONTENEUR_DOCKER/data
CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR=$REP_GIROFLE_CONTENEUR_DOCKER/logs

# - répertoire dédié au backups du conteneur géré dans cette suite d'opérations
REP_BCKUP_CONTENEUR_DOCKER=$REP_GIROFLE_CONTENEUR_DOCKER/bckups
mkdir -p $REP_BCKUP_CONTENEUR_DOCKER
# - répertoire qui sera utilisé pour le backup en cours du conteneur géré dans cette suite d'opérations
REP_BCKUP_COURANT=$REP_BCKUP_CONTENEUR_DOCKER/$OPSTIMESTAMP
mkdir -p $REP_BCKUP_COURANT

sudo rm -rf $REP_BCKUP_COURANT
sudo mkdir -p $REP_BCKUP_COURANT/log
sudo mkdir -p $REP_BCKUP_COURANT/data
sudo mkdir -p $REP_BCKUP_COURANT/config
# Pourquoi sudo? parce que l'utilisateur réalisant le backup, n'est pas forcément doté des droits nécessaires pour copier les fichiers exploités par le process gitlab.
# Voir comissionner des utilisateurs linux plus fins.
sudo cp -Rf $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR/* $REP_BCKUP_COURANT/config
sudo cp -Rf $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR/* $REP_BCKUP_COURANT/log
sudo cp -Rf $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR/* $REP_BCKUP_COURANT/data

echo " +girofle+backup terminé" >> $NOMFICHIERLOG
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


