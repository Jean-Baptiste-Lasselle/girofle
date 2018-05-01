#!/bin/bash

# Hôte Docker sur centos 7

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
#                >>>   export REPERTOIRE_GIROFLE=/girofle
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
##############################################################################################################################################
#####		CONTENEUR CORRESPONDANT À L'INSTANCE GITLAB CONFIGUREE SAML/OAUTH 
##############################################################################################################################################
# - répertoire hôte dédié à l'instance Gitlab
export REP_GIROFLE_INSTANCE_GITLAB
# - Nom du conteneur docker qui sera créé
export NOM_DU_CONTENEUR_CREE
# - répertoires hôte associés
export CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR
export CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR
export CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR

##############################################################################################################################################


##############################################################################################################################################


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							FONCTIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
# Cette fonction mets à jour la valeur de la variable d'environnement [$NEXT_GITLAB_INSTANCE_NUMBER], en
# comptant le nombre de lignes présentes dans le fichier [$INVENTAIRE_GIROFLE]
calculerProchainGitlabInstanceNumber () {
	export COMPTEURTEMP=0
	while read p; do
	  echo "Ligne $COMPTEURTEMP : [$p]" >> $NOMFICHIERLOG
	  echo " " >> $NOMFICHIERLOG
	  # COMPTEURTEMP=$COMPTEURTEMP + 1
	  ((COMPTEURTEMP=COMPTEURTEMP+1))
	done <$INVENTAIRE_GIROFLE
	NEXT_GITLAB_INSTANCE_NUMBER=$COMPTEURTEMP
	echo " +girofle+ [calculerProchainGitlabInstanceNumber ()] VALEUR FINALE [NEXT_GITLAB_INSTANCE_NUMBER=$NEXT_GITLAB_INSTANCE_NUMBER]" >> $NOMFICHIERLOG
}
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
# Cette fonction permet d'attendre que le conteneur soit dans l'état healthy
# Cette fonction prend un argument, nécessaire sinon une erreur est générée (TODO: à implémenter avec exit code)
checkHealth () {
	export ETATCOURANTCONTENEUR=starting
	export ETATCONTENEURPRET=healthy
	export NOM_DU_CONTENEUR_INSPECTE=$1
	
	while  $(echo "+provision+girofle+ $NOM_DU_CONTENEUR_INSPECTE - HEALTHCHECK: [$ETATCOURANTCONTENEUR]">> $NOMFICHIERLOG); do
	
	ETATCOURANTCONTENEUR=$(sudo docker inspect -f '{{json .State.Health.Status}}' $NOM_DU_CONTENEUR_INSPECTE)
	if [ $ETATCOURANTCONTENEUR == "\"healthy\"" ]
	then
		echo "+provision+girofle+ $NOM_DU_CONTENEUR_INSPECTE est prêt - HEALTHCHECK: [$ETATCOURANTCONTENEUR]">> $NOMFICHIERLOG
		break;
	else
		echo "+provision+girofle+ $NOM_DU_CONTENEUR_INSPECTE n'est pas prêt - HEALTHCHECK: [$ETATCOURANTCONTENEUR] - attente d'une seconde avant prochain HealthCheck - ">> $NOMFICHIERLOG
		sleep 1s
	fi
	done
	
	# DEBUG LOGS
	echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
	echo " provision-girofle-  - Contenu du répertoire [/etc/gitlab] dans le conteneur [$NOM_DU_CONTENEUR_INSPECTE]:" >> $NOMFICHIERLOG
	echo " provision-girofle-  - " >> $NOMFICHIERLOG
	sudo docker exec -it $NOM_DU_CONTENEUR_INSPECTE /bin/bash -c "ls -all /etc/gitlab" >> $NOMFICHIERLOG
	echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
	echo " provision-girofle-  - Existence du fichier [/etc/gitlab/gitlab.rb] dans le conteneur  [$NOM_DU_CONTENEUR_INSPECTE]:" >> $NOMFICHIERLOG
	echo " provision-girofle-  - " >> $NOMFICHIERLOG
	sudo docker exec -it $NOM_DU_CONTENEUR_INSPECTE /bin/bash -c "ls -all /etc/gitlab/gitlab.rb" >> $NOMFICHIERLOG
	echo " provision-girofle-  - " >> $NOMFICHIERLOG
	echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
}
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
# Cette fonction permet de rpovisionner uen seconde instance Gitlab sur le même hôte Docker.
# L'intention est de tester la cohabitation de plusieurs cotneneurs contenant cahcun une instance Gitlab.
# Le test, et la recherche d'informations, montrent que la cohabitation de plusieurs instances Gitlab, qu'elles
# soient provisionnées dans des conteneurs docker ou non, nécesssite uen configuration supplémentaire pour chaque
# instance participant à la cohabitation.
provisionInstanceSupplementaire () {
# - création des répertoires associés
# sudo rm -rf $REPERTOIRE_GIROFLE
mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR2
mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR2
mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR2
# changement des valeurs de tests.
# ADRESSE_IP_SRV_GITLAB=192.168.1.33
# NOMDEDOMAINE_INSTANCE_GITLAB=prj-pms.girofle.io
# NOMDEDOMAINE_INSTANCE_GITLAB=test.girofle.io
# sudo docker run --detach --hostname $NOMDEDOMAINE_INSTANCE_GITLAB --publish $ADRESSE_IP_SRV_GITLAB:4433:443 --publish $ADRESSE_IP_SRV_GITLAB:$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST:80 --publish $ADRESSE_IP_SRV_GITLAB:2277:22 --name $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR2:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR2:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR2:$GITLAB_DATA_DIR  $VERSION_IMAGE_OFFICIELLE_DOCKER_GITLAB
sudo docker run --detach --publish $ADRESSE_IP_SRV_GITLAB:4433:443 --publish $ADRESSE_IP_SRV_GITLAB:$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST:80 --publish $ADRESSE_IP_SRV_GITLAB:2277:22 --name $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR2:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR2:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR2:$GITLAB_DATA_DIR  $VERSION_IMAGE_OFFICIELLE_DOCKER_GITLAB
checkHealth $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST >> $NOMFICHIERLOG
# persistance de la nouvelle entrée dans l'inventaire des instances gitlab
# ENTREE_INVENTAIRE=$(" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] + [REP_GIROFLE_INSTANCE_GITLAB_SUPPLEMENTAIRE_POUR_TEST=$REP_GIROFLE_INSTANCE_GITLAB_SUPPLEMENTAIRE_POUR_TEST] + [NOM_DU_CONTENEUR_CREE=$NOM_DU_CONTENEUR_CREE]")
ENTREE_INVENTAIRE=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER2] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] + [REP_GIROFLE_INSTANCE_GITLAB_SUPPLEMENTAIRE_POUR_TEST=$REP_GIROFLE_INSTANCE_GITLAB_SUPPLEMENTAIRE_POUR_TEST] + [NOM_DU_CONTENEUR_CREE=$NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST]"
sudo rm -f $INVENTAIRE_GIROFLE.temp
touch $INVENTAIRE_GIROFLE.temp
sudo chown -R $UTILISATEUR_LINUX_GIROFLE:$UTILISATEUR_LINUX_GIROFLE $INVENTAIRE_GIROFLE.temp
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE.temp
sudo chmod u+r+w $INVENTAIRE_GIROFLE.temp
# on garde les entrées précédentes
sudo cat $INVENTAIRE_GIROFLE >> $INVENTAIRE_GIROFLE.temp
# on ajoute la nouvelle entrée
echo $ENTREE_INVENTAIRE >> $INVENTAIRE_GIROFLE.temp
sudo rm -f $INVENTAIRE_GIROFLE
sudo cp -f $INVENTAIRE_GIROFLE.temp $INVENTAIRE_GIROFLE
sudo chown -R $UTILISATEUR_LINUX_GIROFLE:$UTILISATEUR_LINUX_GIROFLE $INVENTAIRE_GIROFLE
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE
sudo chmod u+r+w $INVENTAIRE_GIROFLE

}

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							OPS								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# 


##############################################################################################################################################
#####		CONTENEUR 1
##############################################################################################################################################
# - répertoire hôte dédié à l'instance Gitlab
REP_GIROFLE_INSTANCE_GITLAB=$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER
# - Nom du conteneur docker qui sera créé
NOM_DU_CONTENEUR_CREE=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER
# - répertoires hôte associés
CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR=$REP_GIROFLE_INSTANCE_GITLAB/config
CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR=$REP_GIROFLE_INSTANCE_GITLAB/data
CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR=$REP_GIROFLE_INSTANCE_GITLAB/logs
# - création des répertoires hôtes associés
# sudo rm -rf $REPERTOIRE_GIROFLE
mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR
mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR
mkdir -p $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR
##############################################################################################################################################

##############################################################################################################################################
#####		CONTENEUR 2 ===>>>> Pour tests du nombre maximal d'instances serveurs possibles sur une même machine...
##############################################################################################################################################
# - répertoire hôte dédié à l'instance Gitlab
REP_GIROFLE_INSTANCE_GITLAB_SUPPLEMENTAIRE_POUR_TEST=$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER2
NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER2
# - répertoires associés
CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR2=$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER2/config
CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR2=$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER2/data
CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR2=$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER2/logs

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

echo " +girofle+ Verification adresse IP: [HOSTNAME=$HOSTNAME] " >> $NOMFICHIERLOG
echo " +girofle+ Verification adresse IP: [NOMDEDOMAINE_INSTANCE_GITLAB=$NOMDEDOMAINE_INSTANCE_GITLAB] " >> $NOMFICHIERLOG
echo " +girofle+ Verification adresse IP: [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] " >> $NOMFICHIERLOG
echo " +girofle+ Verification no. Port IP: [NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_SRV_GITLAB] " >> $NOMFICHIERLOG
echo " +girofle+ Verification no. Port IP: [NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] " >> $NOMFICHIERLOG

##########################################################################################
##########################################################################################
#						construction image docker Girofle.io/Gitlab			  		   	 #
##########################################################################################
##########################################################################################
# 
# Point de distribution: "gitlab/gitlab-ce:latest" : https://hub.docker.com/r/gitlab/gitlab-ce/
export VERSION_IMAGE_OFFICIELLE_DOCKER_GITLAB=gitlab/gitlab-ce:latest
export NOM_IMAGE_DOCKER_INSTANCES_GIROFLE=girolfe.io/image-gitlab:v1.0.0
sudo chmod +x ./construire-image-docker-girofle-gitlab.sh
./construire-image-docker-girofle-gitlab.sh
##########################################################################################
##########################################################################################
#						instance gitlab provisionnée						   		   	 #
##########################################################################################
##########################################################################################
# 
sudo docker run --detach --hostname $NOMDEDOMAINE_INSTANCE_GITLAB --publish $ADRESSE_IP_SRV_GITLAB:433:443 --publish $ADRESSE_IP_SRV_GITLAB:$NO_PORT_IP_SRV_GITLAB:80 --publish $ADRESSE_IP_SRV_GITLAB:2227:22 --name $NOM_DU_CONTENEUR_CREE --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR:$GITLAB_DATA_DIR $NOM_IMAGE_DOCKER_INSTANCES_GIROFLE
checkHealth $NOM_DU_CONTENEUR_CREE >> $NOMFICHIERLOG
# persistance de la nouvelle entrée dans l'inventaire des instances gitlab
# export ENTREE_INVENTAIRE=$(" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_SRV_GITLAB] + [REP_GIROFLE_INSTANCE_GITLAB=$REP_GIROFLE_INSTANCE_GITLAB] + [NOM_DU_CONTENEUR_CREE=$NOM_DU_CONTENEUR_CREE]")
export ENTREE_INVENTAIRE=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_SRV_GITLAB] + [REP_GIROFLE_INSTANCE_GITLAB=$REP_GIROFLE_INSTANCE_GITLAB] + [NOM_DU_CONTENEUR_CREE=$NOM_DU_CONTENEUR_CREE]"
sudo rm -f $INVENTAIRE_GIROFLE.temp
touch $INVENTAIRE_GIROFLE.temp
sudo chown -R $UTILISATEUR_LINUX_GIROFLE:$UTILISATEUR_LINUX_GIROFLE $INVENTAIRE_GIROFLE.temp
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE.temp
sudo chmod u+r+w $INVENTAIRE_GIROFLE.temp
# on garde les entrées précédentes
sudo cat $INVENTAIRE_GIROFLE >> $INVENTAIRE_GIROFLE.temp
# on ajoute la nouvelle entrée
echo $ENTREE_INVENTAIRE >> $INVENTAIRE_GIROFLE.temp
sudo rm -f $INVENTAIRE_GIROFLE
sudo cp -f $INVENTAIRE_GIROFLE.temp $INVENTAIRE_GIROFLE
sudo chown -R $UTILISATEUR_LINUX_GIROFLE:$UTILISATEUR_LINUX_GIROFLE $INVENTAIRE_GIROFLE
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE
sudo chmod u+r+w $INVENTAIRE_GIROFLE


