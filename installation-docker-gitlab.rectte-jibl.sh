# Installation de Docker sur centos 7

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							ENV								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# - Variables d'environnement héritées de "operations.sh":
# 				 # le numéro de port IP qui sera utilisé par le connecteur HTTP de l'instance Gitlab
#                >>>   export NO_PORT_IP_SRV_GITLAB
# 				 # l'adresse IP qui sera utilisée par les connecteurs HTTP/HTTPS de l'instance Gitlab
#                >>>   export ADRESSE_IP_SRV_GITLAB
# 				 # le fichier de log des opérations
#                >>>   export NOMFICHIERLOG="$(pwd)/provision-girofle.log"
# 				 # le répertoire d'exploitation Girofle
#                >>>   export REP_GESTION_CONTENEURS_DOCKER=/girofle
# 				 # le numéro de port de l'instance Gitalb de test supplémentaire
#                >>>   export NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=8880
# --------------------------------------------------------------------------------------------------------------------------------------------
# export ADRESSE_IP_SRV_GITLAB


# --------------------------------------------------------------------------------------------------------------------------------------------
export NEXT_GITLAB_INSTANCE_NUMBER
export GITLAB_INSTANCE_NUMBER=1
export GITLAB_INSTANCE_NUMBER2=2
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
calculerProchainGitlabInstanceNumber
export REP_GIROFLE_CONTENEUR_DOCKER
##############################################################################################################################################
#####		CONTENEUR 1
##############################################################################################################################################
# - répertoire hôte dédié à l'instance Gitlab
export REP_GIROFLE_CONTENEUR_DOCKER
# - Nom du conteneur docker qui sera créé
export NOM_DU_CONTENEUR_CREE
# - répertoires hôte associés
export CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR
export CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR
export CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR

##############################################################################################################################################

##############################################################################################################################################
#####		CONTENEUR 2 ===>>>> Pour tests du nombre maximal d'instances serveurs possibles sur une même machine...
#####		Je commence par tester la possibilité de binder deux mêmes conteneurs usdr la même adresse IP, mais avec des numéros de ports différents.
#####		Je limiterai le nombre maximal au nombre maximal de hostnames/nomsdedomaines, ce nombre d'instances.
##############################################################################################################################################
# - répertoire hôte dédié à l'instance Gitlab
# export REP_GIROFLE_CONTENEUR_DOCKER
# - Nom du conteneur docker qui sera créé
export NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST
# - répertoires hôte associés
export CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR2
export CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR2
export CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR2

##############################################################################################################################################


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							FONCTIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander iteractivement à l'utilisateur du
# script, quel numéro de port IP, la seconde instance Gitlab de Test pourra utiliser dans l'hôte Docker
demander_noPortIP_InstanceTest () {

	echo "Quelle adresse IP souhaitez-vous que l'instance gitlab utilise?"
	echo "Cette adresse est à  choisir parmi:"
	echo " "
	ip addr|grep "inet"|grep -v "inet6"|grep "enp\|wlan"
	echo " "
	read NO_PORT_IP_CHOISIT
	if [ "x$NO_PORT_IP_CHOISIT" = "x" ]; then
       NO_PORT_IP_CHOISIT=80
	fi
	
	NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_CHOISIT
	echo " Binding Adresse IP choisit pour le serveur gitlab: $NO_PORT_IP_CHOISIT";
}

# Cette fonction emts à jour la valeur de la vriable d'environnement [$NEXT_GITLAB_INSTANCE_NUMBER]
calculerProchainGitlabInstanceNumber () {
	COMPTEURTEMP=0
	while read p; do
	  echo "Ligne $COMPTEURTEMP : [$p]"
	  echo " "
	  # COMPTEURTEMP=$COMPTEURTEMP + 1
	  ((COMPTEURTEMP=COMPTEURTEMP+1))
	done <./fichiertest
	NEXT_GITLAB_INSTANCE_NUMBER=$COMPTEURTEMP
	echo " +girofle+ [calculerProchainGitlabInstanceNumber ()] VALEUR FINALE [NEXT_GITLAB_INSTANCE_NUMBER=$NEXT_GITLAB_INSTANCE_NUMBER]" >> $NOMFICHIERLOG
	echo " Binding Adresse IP choisit pour le serveur gitlab: $NO_PORT_IP_CHOISIT";
}



# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							OPS								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
calculerProchainGitlabInstanceNumber



##############################################################################################################################################
#####		CONTENEUR 1
##############################################################################################################################################
# - répertoire hôte dédié à l'instance Gitlab
REP_GIROFLE_CONTENEUR_DOCKER=$REP_GESTION_CONTENEURS_DOCKER/noeud-gitlab-$GITLAB_INSTANCE_NUMBER
# - Nom du conteneur docker qui sera créé
NOM_DU_CONTENEUR_CREE=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER
# - répertoires hôte associés
CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR=$REP_GIROFLE_CONTENEUR_DOCKER/config
CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR=$REP_GIROFLE_CONTENEUR_DOCKER/data
CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR=$REP_GIROFLE_CONTENEUR_DOCKER/logs
# - création des répertoires hôtes associés
sudo rm -rf $REP_GESTION_CONTENEURS_DOCKER
sudo mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR
sudo mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR
sudo mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR
##############################################################################################################################################

##############################################################################################################################################
#####		CONTENEUR 2 ===>>>> Pour tests du nombre maximal d'instances serveurs possibles sur une même machine...
##############################################################################################################################################
# - répertoire hôte dédié à l'instance Gitlab
REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST=$REP_GESTION_CONTENEURS_DOCKER/noeud-gitlab-$GITLAB_INSTANCE_NUMBER2
NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER2
# - répertoires associés
CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR2=$REP_GESTION_CONTENEURS_DOCKER/noeud-gitlab-$GITLAB_INSTANCE_NUMBER2/config
CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR2=$REP_GESTION_CONTENEURS_DOCKER/noeud-gitlab-$GITLAB_INSTANCE_NUMBER2/data
CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR2=$REP_GESTION_CONTENEURS_DOCKER/noeud-gitlab-$GITLAB_INSTANCE_NUMBER2/logs
# - création des répertoires associés
# sudo rm -rf $REP_GESTION_CONTENEURS_DOCKER
sudo mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR
sudo mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR
sudo mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR
##############################################################################################################################################


##############################################################################################################################################
#####		CREATION INSTANCES GITLAB
##############################################################################################################################################
#####		TODO: faire la fonction qui demandera le nom Girofle de la nouvelle instance gitlab
##############################################################################################################################################
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

# donc pour ce test, le numéro de port choisit ne peut êtrele même que pour le second conteneur de test
if [ $NO_PORT_IP_SRV_GITLAB = "8880" ] 
then
echo "attention,  le numéro de port [$NO_PORT_IP_SRV_GITLAB] est celui qui sera utilisé par une seconde instance Gitlab pour ce test:"
echo "Choisissez un autre numéro de port pour la seconde instance (de test)."
demander_noPortIP_InstanceTest
fi

echo " +girofle+ Verification adresse IP: [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] " >> $NOMFICHIERLOG
echo " +girofle+ Verification no. Port IP: [NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_SRV_GITLAB] " >> $NOMFICHIERLOG

# instance à la demande
sudo docker run --detach --hostname $HOSTNAME --publish $ADRESSE_IP_SRV_GITLAB:433:443 --publish $ADRESSE_IP_SRV_GITLAB:$NO_PORT_IP_SRV_GITLAB:80 --publish $ADRESSE_IP_SRV_GITLAB:2227:22 --name $NOM_DU_CONTENEUR_CREE --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR:$GITLAB_DATA_DIR gitlab/gitlab-ce:latest
# entrée inventaire afférente
export ENTREE_INVENTAIRE=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_SRV_GITLAB] + [REP_GIROFLE_CONTENEUR_DOCKER=$REP_GIROFLE_CONTENEUR_DOCKER] + [NOM_DU_CONTENEUR_CREE=$NOM_DU_CONTENEUR_CREE]"
echo $INVENTAIRE_GIROFLE >> $INVENTAIRE_GIROFLE.temp
echo $ENTREE_INVENTAIRE >> $INVENTAIRE_GIROFLE.temp
sudo rm -f $INVENTAIRE_GIROFLE
sudo cp -f $INVENTAIRE_GIROFLE.temp $INVENTAIRE_GIROFLE
sudo chown -R $USER:$USER $INVENTAIRE_GIROFLE
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE
sudo chmod u+r+w $INVENTAIRE_GIROFLE



# instance supplémentaire de test
sudo docker run --detach --hostname $HOSTNAME --publish $ADRESSE_IP_SRV_GITLAB:4433:443 --publish $ADRESSE_IP_SRV_GITLAB:$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST:80 --publish $ADRESSE_IP_SRV_GITLAB:2277:22 --name $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR2:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR2:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR2:$GITLAB_DATA_DIR gitlab/gitlab-ce:latest
# entrée inventaire afférente
export ENTREE_INVENTAIRE=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] + [REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST=$REP_GIROFLE_CONTENEUR_DOCKER_SUPPLEMENTAIRE_POUR_TEST] + [NOM_DU_CONTENEUR_CREE=$NOM_DU_CONTENEUR_CREE]"
echo $INVENTAIRE_GIROFLE >> $INVENTAIRE_GIROFLE.temp
echo $ENTREE_INVENTAIRE >> $INVENTAIRE_GIROFLE.temp
sudo rm -f $INVENTAIRE_GIROFLE
sudo cp -f $INVENTAIRE_GIROFLE.temp $INVENTAIRE_GIROFLE
sudo chown -R $USER:$USER $INVENTAIRE_GIROFLE
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE
sudo chmod u+r+w $INVENTAIRE_GIROFLE


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


