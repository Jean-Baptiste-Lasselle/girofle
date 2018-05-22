#!/bin/bash
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
# 
# --------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# 
# 
# Guide de l'utilisateur.
# -----------------------
# 
#		http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1708.iso
#		http://miroir.univ-paris13.fr/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1708.iso
#
# Nous utiliserons:
# 
# 	+ une VM [MachineHote], sur laquelle a été installé centos 7.4 . Les scripts ont été testés dans un environnement tel que :
#
#			[cat /etc/centos-release] imprime sur la sortie standard:
#			[CentOS Linux release 7.4.1708 (Core)]
#			[uname] imprime sur la sortie standard:
#			[CentOS Linux release 7.4.1708 (Core)]
# 
# 	+ 1 script:
# 
#  		- [bare-metal-docker-demo-BARE-METAL-SETUP.sh]
# 
# 1./ Ouvrir une session sftp avec WinSCP par exemple, vers la [MachineHote], puis 
# 	  copier le présent fichier "bare-metal-docker-demo-BARE-METAL-SETUP.sh" dans un
#	  répertoire dans [MachineHote].
# 
# 2./ Ouvrir une session ssh vers [MachineHote], puis exécuter : 
# 
# 			[sudo chmod +x ./bare-metal-docker-demo-BARE-METAL-SETUP.sh]
# 			[sudo ./bare-metal-docker-demo-BARE-METAL-SETUP.sh]
# 

# http://$CENTRALIZED_ID_MGMT_USERNAME:$CENTRALIZED_ID_MGMT_PWD@manh.proxy.corp.sopra:8080/
# http://jlasselle:5Hm{X&7s4@manh.proxy.corp.sopra:8080/

# -----------------------------------------------------------------------------------------------------------------------
# Configuration du client docker pour le proxy spécificique à l'infrastruture cible de déploiement
# -----------------------------------------------------------------------------------------------------------------------
#
export OPERATEUR_DOCKER=$USER
sudo su $OPERATEUR_DOCKER
cd $HOME