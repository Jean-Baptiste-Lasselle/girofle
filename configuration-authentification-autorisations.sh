#!/bin/bash

# Hôte Docker sur centos 7
# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							RESUME							##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# Ce script a pour but d'appliquer dans le conteneur [$NOM_DU_CONTENEUR_RECONFIGURE], les changements nécessaires pour reconfigurer
# L'instance Gitlab de manière à ce qu'elle ait une authentification de type SAML / OAuth2, avecf les paramètres suivants:
# 
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
export NOM_DU_CONTENEUR_RECONFIGURE
export NOM_DU_CONTENEUR_RECONFIGURE_PARDEFAUT=conteneur-kytes.io.gitlab.1
# - répertoires hôte associés
export CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR
export CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR
export CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR

##############################################################################################################################################
#####		CONTENEUR 1
##############################################################################################################################################
# - répertoire hôte dédié à l'instance Gitlab
REP_GIROFLE_INSTANCE_GITLAB=$REPERTOIRE_GIROFLE/noeud-gitlab-$GITLAB_INSTANCE_NUMBER
# - Nom du conteneur docker qui sera créé
NOM_DU_CONTENEUR_RECONFIGURE=conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER
# - répertoires hôte associés
CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR=$REP_GIROFLE_INSTANCE_GITLAB/config
CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR=$REP_GIROFLE_INSTANCE_GITLAB/data
CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR=$REP_GIROFLE_INSTANCE_GITLAB/logs

##############################################################################################################################################
# Point de distribution: "gitlab/gitlab-ce:latest" : https://hub.docker.com/r/gitlab/gitlab-ce/
export VERSION_IMAGE_OFFICIELLE_DOCKER_GITLAB=gitlab/gitlab-ce:latest
export NOM_IMAGE_DOCKER_INSTANCES_GIROFLE=girolfe.io/image-gitlab:v1.0.0

##############################################################################################################################################


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							FONCTIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
# Cette fonction ...

# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet d'intialiser, éventuellement interactivement, la valeur du nom ou l'ID / hash du conteneur Docker exécutant
# l'instance Gitlab à reconfigurer
initialiser_nomConteneurInstanceGitlab () {

NOM_DU_CONTENEUR_RECONFIGURE=""
NOM_DU_CONTENEUR_RECONFIGURE=$1
if [ "x$NOM_DU_CONTENEUR_RECONFIGURE" = "x" ]; then
	echo " -- "
	echo " Quel est le nom du contneur Docker contenant l'instance Gitlab à reconfigurer?"
	echo " -- "
	echo " Valeur qui sera appliquée par défaut (en pressant la touche Entrée):"
	echo "     [$NOM_DU_CONTENEUR_RECONFIGURE_PAR_DEFAUT] "
	echo " "
	read NOM_CONTENEUR_CHOISIT
	if [ "x$NOM_CONTENEUR_CHOISIT" = "x" ]; then
       NOM_CONTENEUR_CHOISIT=$NOM_DU_CONTENEUR_RECONFIGURE_PAR_DEFAUT
	fi
	NOM_DU_CONTENEUR_RECONFIGURE=$NOM_DOMAINE_CHOISIT
fi
echo "  Nom du conteneur dont l'authentification et le système de gestion des autorisations sont re-configurés pour utiliser [SAML / OAuth2] : $NOM_DU_CONTENEUR_RECONFIGURE" >> $NOMFICHIERLOG
}


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							OPS								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# 

echo " +girofle+ Verification adresse IP: [HOSTNAME=$HOSTNAME] " >> $NOMFICHIERLOG
echo " +girofle+ Verification adresse IP: [NOMDEDOMAINE_INSTANCE_GITLAB=$NOMDEDOMAINE_INSTANCE_GITLAB] " >> $NOMFICHIERLOG
echo " +girofle+ Verification adresse IP: [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] " >> $NOMFICHIERLOG
echo " +girofle+ Verification no. Port IP: [NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_SRV_GITLAB] " >> $NOMFICHIERLOG
echo " +girofle+ Verification no. Port IP: [NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] " >> $NOMFICHIERLOG

initialiser_nomConteneurInstanceGitlab

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


 