#!/bin/bash

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							ENV								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------
# - Logging des opérations
# ---------------------------------------
export NOMFICHIERLOG="$(pwd)/provision-girofle.log"
rm -f $NOMFICHIERLOG
touch $NOMFICHIERLOG
# ---------------------------------------
# - répertoires  dans l'hôte docker
# ---------------------------------------
export REPERTOIRE_GIROFLE=/girofle
# pour l'auto-incrémentation: à chaque fois qu'une nouvelle instance est créée avec succès, une nouvelle ligne est ajoutée dans ce fichier
export COMPTEUR_GIROFLE=$REPERTOIRE_GIROFLE/.auto-increment.girofle
# à remplacer par une petite bdd embarquée de type nosql, .h2, pour au moins avoir gestion des accès concconcurrents, et enfin à remplacer par [etcd]
export INVENTAIRE_GIROFLE=$REPERTOIRE_GIROFLE/inventory.girofle
# ---------------------------------------
# - instance Gitlab provisionnée
# ---------------------------------------
# le nom de domaine par lequel sera accédée la premièe instance Gitlab lancée par Girofle:
#" Celle provisionnée à l'installation de girofle.
export NOMDEDOMAINE_INSTANCE_GITLAB
export NOMDEDOMAINE_INSTANCE_GITLAB_PAR_DEFAUT
NOMDEDOMAINE_INSTANCE_GITLAB_PAR_DEFAUT=prj-pms.girofle.io
# l'adresse IP qui sera utilisée par les connecteurs HTTP/HTTPS de l'instance Gitlab
export ADRESSE_IP_SRV_GITLAB
export ADRESSE_IP_SRV_GITLAB_PAR_DEFAUT
ADRESSE_IP_SRV_GITLAB_PAR_DEFAUT=0.0.0.0
# l'adresse IP qui sera utilisée par les connecteurs HTTP/HTTPS de la seconde instance Gitlab
export ADRESSE_IP_SRV_GITLAB2
export ADRESSE_IP_SRV_GITLAB2_PAR_DEFAUT
ADRESSE_IP_SRV_GITLAB2_PAR_DEFAUT=0.0.0.0

# le numéro de port IP qui sera utilisé par le connecteur HTTP de l'instance Gitlab
export NO_PORT_IP_SRV_GITLAB
export NO_PORT_IP_SRV_GITLAB_PAR_DEFAUT
NO_PORT_IP_SRV_GITLAB_PAR_DEFAUT=80
# le numéro de port IP qui sera utilisé par le connecteur HTTP de la seconde instance Gitlab
export NO_PORT_IP_SRV_GITLAB2
export NO_PORT_IP_SRV_GITLAB2_PAR_DEFAUT
NO_PORT_IP_SRV_GITLAB2_PAR_DEFAUT=8880


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							PROXies						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
export PROXY_HOST=rumpfelschtilsche
export PROXY_HOST_PAR_DEFAUT=127.0.0.1
export PROXY_NO_PORT_IP=1238569
export PROXY_NO_PORT_IP_PAR_DEFAUT=8080
export PROXY_AUTH_USERNAME_CREDENTIAL=jlasselle
export PROXY_AUTH_USERNAME_CREDENTIAL_PAR_DEFAUT=maisbonsangmaiscbiensur
export PROXY_AUTH_PWD_CREDENTIAL=jailairdeversionnermesmotsdepassesfranchement
# - Sert au moins pour récupérer le nom de l'utilisateur linux qui effecuera les opérations sur l'hôte Docker.
export OPERATEUR_SOLUTION=$USER
# export OPERATEUR_SOLUTION_MDP=jailairdeversionnermesmotsdepassesfranchement


demander_infosProxy () {

	clear
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# ---------------				PROXY_HOST			"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "Quelle est l'adresse IP / le nom d'hôte (nom de domaine par exemple), du proxy qui devra être utilisé?"
	echo "Ce proxy sera tuilisé par les systèmes s'exécutant à l'intérieur des conteneurs Docker, et par Docker pour faire des oéperations comme [docker pull $NOMDUNEIMAGESURUN_DOCKERHUB]."
	echo " "
	ip addr|grep "inet"|grep -v "inet6"|grep "enp\|wlan"
	echo " "
	echo " (Par défaut, l'adresse IP utilisée sera [$PROXY_HOST_PAR_DEFAUT]) "
	read PROXY_HOST_CHOISIT
	if [ "x$PROXY_HOST_CHOISIT" = "x" ]; then
       PROXY_HOST_CHOISIT=$PROXY_HOST_PAR_DEFAUT
	fi
	
	PROXY_HOST=$PROXY_HOST_CHOISIT
	echo " L'hôte réseau hébergeant le serveur PROXY est: $PROXY_HOST" >> $NOMFICHIERLOG
	
	clear
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# ---------------				PROXY_NO_PORT_IP			"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "Quelle est l'adresse IP / le nom d'hôte (nom de domaine par exemple), du proxy qui devra être utilisé?"
	echo "Ce proxy sera tuilisé par les systèmes s'exécutant à l'intérieur des conteneurs Docker, et par Docker pour faire des oéperations comme [docker pull $NOMDUNEIMAGESURUN_DOCKERHUB]."
	echo " "
	ip addr|grep "inet"|grep -v "inet6"|grep "enp\|wlan"
	echo " "
	echo " (Par défaut, l'adresse IP utilisée sera [$PROXY_NO_PORT_IP_PAR_DEFAUT]) "
	read PROXY_NO_PORT_IP_CHOISIT
	if [ "x$PROXY_HOST_CHOISIT" = "x" ]; then
       PROXY_NO_PORT_IP_CHOISIT=$PROXY_NO_PORT_IP_PAR_DEFAUT
	fi
	
	PROXY_NO_PORT_IP=$PROXY_NO_PORT_IP_CHOISIT
	echo " Le numéro de port utilisé par le serveur PROXY est: $PROXY_NO_PORT_IP" >> $NOMFICHIERLOG
	
	clear
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# ---------------				PROXY_AUTH_USERNAME_CREDENTIAL			"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "Quelle est le nom d'utilisateur à utiliser pour s'authentifier auprès du serveur Proxy [PROXY_HOST=$PROXY_HOST]?"
	echo "Ce proxy sera donc utilisé par les systèmes s'exécutant à l'intérieur des conteneurs Docker, et "
	echo "par Docker pour faire des opérations comme [docker pull $NOMDUNEIMAGESURUN_DOCKERHUB]. "
	echo " "
	echo " "
	echo " (Par défaut, l'adresse IP utilisée sera [$PROXY_NO_PORT_IP_PAR_DEFAUT]) "
	read PROXY_AUTH_USERNAME_CREDENTIAL_CHOISIT
	if [ "x$PROXY_HOST_CHOISIT" = "x" ]; then
       PROXY_AUTH_USERNAME_CREDENTIAL_CHOISIT=$PROXY_AUTH_USERNAME_CREDENTIAL_PAR_DEFAUT
	fi
	PROXY_AUTH_USERNAME_CREDENTIAL=$PROXY_AUTH_USERNAME_CREDENTIAL_CHOISIT
	echo " Le numéro de port utilisé par le serveur PROXY est: $PROXY_AUTH_USERNAME_CREDENTIAL" >> $NOMFICHIERLOG
	
	clear
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# ---------------				PROXY_AUTH_PWD_CREDENTIAL			"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "Quelle est le mot de passe de [$PROXY_AUTH_USERNAME_CREDENTIAL] pour s'authentifier auprès du serveur Proxy [PROXY_HOST=$PROXY_HOST]?"
	echo "Ce proxy sera donc utilisé par les systèmes s'exécutant à l'intérieur des conteneurs Docker, et "
	echo "par Docker pour faire des opérations comme [docker pull $NOMDUNEIMAGESURUN_DOCKERHUB]. "
	echo " "
	read PROXY_AUTH_PWD_CREDENTIAL_CHOISIT
	if [ "x$PROXY_HOST_CHOISIT" = "x" ]; then
       echo "Aucun mot de passe n'a été saisit par $USER  pour s'authentifier auprès du Proxy [PROXY_HOST=$PROXY_HOST] avec l'utilisateur [$PROXY_AUTH_PWD_CREDENTIAL] "
	   exit 1
	fi
	PROXY_AUTH_PWD_CREDENTIAL=$PROXY_AUTH_PWD_CREDENTIAL_CHOISIT
	echo " Le mot de passe utilisé par [$PROXY_AUTH_USERNAME_CREDENTIAL] pour s'authentifier auprès du Proxy [PROXY_HOST=$PROXY_HOST] avec l'utilisateur [$PROXY_AUTH_PWD_CREDENTIAL], est : $PROXY_AUTH_PWD_CREDENTIAL" >> $NOMFICHIERLOG
	
	# ATTENTION, CET AFFICHAGE NE DOIT JAMAIS PARTIR EN PROD!!!!!
	# ATTENTION, CET AFFICHAGE NE DOIT JAMAIS PARTIR EN PROD!!!!!
	clear
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# ---------------				Résumé CONFIG AUTH PROXY			"
	echo "# ---------------				"
	echo "# ---------------				+ ATTENTION, CET AFFICHAGE NE DOIT JAMAIS PARTIR EN PROD!!!!!"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# ------------			[PROXY_HOST=$PROXY_HOST]		"
	echo "# ------------			[PROXY_NO_PORT_IP=$PROXY_NO_PORT_IP]		"
	echo "# ------------			[PROXY_AUTH_USERNAME_CREDENTIAL=$PROXY_AUTH_USERNAME_CREDENTIAL]		"
	echo "# ------------			[PROXY_AUTH_PWD_CREDENTIAL=$PROXY_AUTH_PWD_CREDENTIAL]		"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo "# --------------------------------------------------------------------------------------------------------------------------------------------"
	echo " "
	read DEBOGGAGECONFIGPROXY
}

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							FONCTIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander iteractivement à l'utilisateur du
# script, quelle est l'adresse IP, dans l'hôte Docker, que l'instance Gitlab pourra utiliser
#
demander_addrIP () {

	echo "Quelle adresse IP souhaitez-vous que l'instance gitlab utilise?"
	echo "Cette adresse est à  choisir parmi:"
	echo " "
	ip addr|grep "inet"|grep -v "inet6"|grep "enp\|wlan"
	echo " "
	echo " (Par défaut, l'adresse IP utilisée sera [$ADRESSE_IP_SRV_GITLAB_PAR_DEFAUT]) "
	read ADRESSE_IP_CHOISIE
	if [ "x$ADRESSE_IP_CHOISIE" = "x" ]; then
       ADRESSE_IP_CHOISIE=$ADRESSE_IP_SRV_GITLAB_PAR_DEFAUT
	fi
	
	ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_CHOISIE
	echo " Binding Adresse IP choisit pour le serveur gitlab: $ADRESSE_IP_SRV_GITLAB" >> $NOMFICHIERLOG
}


# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander iteractivement à l'utilisateur du
# script, quelle est l'adresse IP, dans l'hôte Docker, que la seconde instance Gitlab pourra utiliser
# -
# Cette fonction doit TOUJOURS être appelée après la fonction [demander_addrIP ()]
#
demander_addrIP_SecondeInstance () {

	echo "Quelle adresse IP souhaitez-vous que la seconde instance gitlab utilise?"
	echo "Cette adresse est à  choisir parmi:"
	echo " "
	ip addr|grep "inet"|grep -v "inet6"|grep "enp\|wlan"
	echo " "
	echo " et doit être différente de $ADRESSE_IP_SRV_GITLAB"
	echo " "
	echo " (Par défaut, l'adresse IP utilisée sera [$ADRESSE_IP_SRV_GITLAB_PAR_DEFAUT]) "
	read ADRESSE_IP_CHOISIE2
	if [ "x$ADRESSE_IP_CHOISIE" = "x" ]; then
       ADRESSE_IP_CHOISIE2=$ADRESSE_IP_SRV_GITLAB_PAR_DEFAUT
	fi
	
	ADRESSE_IP_SRV_GITLAB2=$ADRESSE_IP_CHOISIE2
	echo " Binding Adresse IP choisit pour le serveur gitlab: $ADRESSE_IP_SRV_GITLAB2" >> $NOMFICHIERLOG
}


# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander iteractivement à l'utilisateur du
# script, quel numéro de port IP, que l'instance Gitlab pourra utiliser dans l'hôte Docker
demander_noPortIP () {

	echo "Quel numéro de port IP souhaitez-vous que l'instance gitlab utilise?"
	echo "Ce numéro de port doit être compris entre 1000 et 65535, et ne  pas être dans la liste suivante:"
	echo "(Par défaut, le numéro de port utilisé sera le port [$NO_PORT_IP_SRV_GITLAB_PAR_DEFAUT])"
	# echo " TODO: afficher la liste des numéros de ports utilisés"
	echo " "
	cat $INVENTAIRE_GIROFLE
	echo " "
	read NO_PORT_IP_CHOISIT
	if [ "x$NO_PORT_IP_CHOISIT" = "x" ]; then
       NO_PORT_IP_CHOISIT=$NO_PORT_IP_SRV_GITLAB_PAR_DEFAUT
	fi
	
	NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_CHOISIT
	echo " Binding Adresse IP choisit pour le serveur gitlab: $NO_PORT_IP_CHOISIT" >> $NOMFICHIERLOG
}


# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quel numéro de port IP, la seconde instance Gitlab de Test pourra utiliser dans l'hôte Docker
demander_noPortIP_SecondeInstance () {

	echo "À l'adresse IP [$ADRESSE_IP_SRV_GITLAB], quel numéro de port IP souhaitez-vous que l'instance gitlab TEST utilise?"
	echo "Vous devez choisir un numéro de port, par exemple entre 2000 et 60 000, différent du numéro "
	echo "de port [$NO_PORT_IP_SRV_GITLAB], utilisé par l'instance Gitlab initiale provisionnée avec Girofle."
	echo "(le numéro de port utilisé par défaut sera : [$NO_PORT_IP_SRV_GITLAB2_PAR_DEFAUT])"
	echo " "
	read NO_PORT_IP_CHOISIT2
	if [ "x$NO_PORT_IP_CHOISIT" = "x" ]; then
       NO_PORT_IP_CHOISIT2=$NO_PORT_IP_SRV_GITLAB2_PAR_DEFAUT
	fi
	NO_PORT_IP_SRV_GITLAB2=$NO_PORT_IP_CHOISIT2
	echo " Binding Adresse IP choisit pour le serveur gitlab de tests: $NO_PORT_IP_SRV_GITLAB2" >> $NOMFICHIERLOG
}


# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quel nom de domaine il souhaite utilsier pour l'accès aux instances Gitlab de Girofle.
demander_nomDomaineSouhaite () {

	echo "Quel nom de domaine souhaitez-vous que l'instance gitlab provisionnée à l'installation de Girofle utilise?"
	echo "(Appuyez simpmlement sur la touche entrée pour appliquer la valeur par défaut: [$NOMDEDOMAINE_INSTANCE_GITLAB_PAR_DEFAUT]) "
	echo " "
	read NOM_DOMAINE_CHOISIT
	if [ "x$NOM_DOMAINE_CHOISIT" = "x" ]; then
       NOM_DOMAINE_CHOISIT=$NOMDEDOMAINE_INSTANCE_GITLAB_PAR_DEFAUT
	fi
	NOMDEDOMAINE_INSTANCE_GITLAB=$NOM_DOMAINE_CHOISIT
	echo "  Binding Adresse IP choisit pour le serveur gitlab de tests: $NOMDEDOMAINE_INSTANCE_GITLAB" >> $NOMFICHIERLOG
}


# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de relancer le réseau, notamment pour relancer une requête DHCP, et mettre à jur le serveur de nom de domaine de la box FAI
# +++ >>> L'appel de cette fonction est rendu obligatoire par l'exécution de la fonction [reconfigurer_interfaces_reseau ()] du script [changement-hostname-nom-domaijne.sh]
relancer_reseau () {
# comment obtenir la liste des interfaces réseaux, pour les re-démarrer
ip addr >> ./listeinterfaces
LISTE_NOMS_INTERFACES=$(awk  -F':' '/enp0s*/ {print $2; echo "okok"}' ./listeinterfaces|awk  -F':' '/enp0s*/ {print $1}'|awk '/enp0s*/ {$1=$1;print}')

for NOM_INTERFACE_RESEAU in $LISTE_NOMS_INTERFACES
do
sudo ip addr flush $NOM_INTERFACE_RESEAU >> $NOMFICHIERLOG
# echo "reconfiguration: $NOM_INTERFACE_RESEAU"
done
# sudo systemctl restart network
# echo 'exécutez maintenant : [sudo systemctl restart network]'

}

incrementerCompteurGirofle () {
echo "nouvelleligne"  $COMPTEUR_GIROFLE
}


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							OPS								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
export UTILISATEUR_LINUX_GIROFLE
# UTILISATEUR_LINUX_GIROFLE=girofle
UTILISATEUR_LINUX_GIROFLE=$USER
echo " +provision+girofle+  COMMENCEE  - " >> $NOMFICHIERLOG
# on crée le répertoire Girofle
sudo rm -rf $REPERTOIRE_GIROFLE
sudo mkdir -p $REPERTOIRE_GIROFLE
# On rend à César, ce qui est à César
sudo chown -R $USER:$USER $REPERTOIRE_GIROFLE
# On initialise le compteur Girofle:
sudo rm -f $COMPTEUR_GIROFLE
touch $COMPTEUR_GIROFLE
sudo chown -R $USER:$USER $COMPTEUR_GIROFLE
sudo chmod a-r-w-x $COMPTEUR_GIROFLE
sudo chmod g+r+w $COMPTEUR_GIROFLE
# On initialise l'inventaire:
sudo rm -f $INVENTAIRE_GIROFLE
touch $INVENTAIRE_GIROFLE
sudo chown -R $UTILISATEUR_LINUX_GIROFLE:$UTILISATEUR_LINUX_GIROFLE $INVENTAIRE_GIROFLE
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE
# sudo chmod g+r+w $INVENTAIRE_GIROFLE
sudo chmod u+r+w $INVENTAIRE_GIROFLE

# On rend exécutables les dépendances
sudo chmod +x ./docker-BARE-METAL-SETUP.sh
sudo chmod +x ./installation-docker-gitlab.rectte-jibl.sh
sudo chmod +x ./changement-hostname-nom-domaine.sh
sudo chmod +x ./configurer-backup-automatique.sh
sudo chmod +x ./relancer-reseau.sh
# On s'assure de l'adresse et du numéro de port IP qui seront utilisés (par l'instance Gitlab qui sera créée)
clear
echo "   "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " +provision+girofle+  Configuration de l'instance Gitlab intialement provisionnée par Girofle: "
echo " +provision+girofle+  NOM DE DOMAINE "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo "   "
demander_nomDomaineSouhaite
clear
echo "   "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " +provision+girofle+  Configuration de l'instance Gitlab intialement provisionnée par Girofle: "
echo " +provision+girofle+  ADRESSE IP "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo "   "
demander_addrIP
demander_addrIP_SecondeInstance
clear
echo "   "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " +provision+girofle+  Configuration de l'instance Gitlab intialement provisionnée par Girofle: "
echo " +provision+girofle+  NO. PORT IP - accès lecture HTTPS repo gits "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo "   "
demander_noPortIP
demander_noPortIP_SecondeInstance



demander_infosProxy

# NO_PORT_IP_SRV_GITLAB2=$NO_PORT_IP_SRV_GITLAB2_PAR_DEFAUT
# update CentOS 7

sudo rm -rf /var/cache/yum && sudo yum clean all -y && sudo yum update -y
# ---------------------------------------------------------------------------------------------------------------------------------------------
# ------	RECONFIGURATION DU RESEAU
# ---------------------------------------------------------------------------------------------------------------------------------------------
# 
# En vertu de la recommandation officielle : 
# 
# https://success.docker.com/article/should-you-use-networkmanager
# 
# On désactive le NetworkManager, qui ne doit PAS être utilisé dans un système hôte docker:
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
# on ira jsuqu'à le désinstaller:
sudo yum remove -y NetworkManager && sudo rm -rf /var/cache/yum && sudo yum clean all -y

# On change config hostname/nomdomaine pour adopter girofle
./changement-hostname-nom-domaine.sh

# echo "PAUSE DEBUG - CONFIG RESEAU - AVANT RELANCE RESEAU "
# read DEBUG

./relancer-reseau.sh

# echo "PAUSE DEBUG - CONFIG RESEAU - APRES RELANCE RESEAU "
# read DEBUG


# ---------------------------------------------------------------------------------------------------------------------------------------------
# ------	SYNCHRONSITATION SUR UN SERVEUR NTP PUBLIC (Y-en-a-til des gratuits dont je puisse vérifier le certificat SSL TLSv1.2 ?)
# ---------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------
# ---	Pour commencer, pour ne PAS FAIRE PETER TOUS LES CERTIFICATS SSL vérifiés pour les installation yum
# ---	
# ---	Sera aussi utilise pour a provision de tous les noeuds d'infrastructure assurant des fonctions d'authentification:
# ---		Le serveur Free IPA Server
# ---		Le serveur OAuth2/SAML utilisé par/avec Free IPA Server, pour gérer l'authentification 
# ---		Le serveur Let's Encrypt et l'ensemble de l'infrastructure à clé publique gérée par Free IPA Server
# ---		Toutes les macines gérées par Free-IPA Server, donc les hôtes réseau exécutant des conteneurs Girofle
# 
# 
# >>>>>>>>>>> Mais en fait la synchronisation NTP doit se faire sur un référentiel commun à la PKI à laquelle on choisit
# 			  de faire confiance pour l'ensemble de la provision. Si c'est une PKI entièrement interne, alors le système 
# 			  comprend un repository linux privé contenant tous les packes à installer, dont docker-ce.
# 
# ---------------------------------------------------------------------------------------------------------------------------------------------
echo "date avant la re-synchronisation [Serveur NTP=$SERVEUR_NTP :]" >> $NOMFICHIERLOG
date >> $NOMFICHIERLOG
sudo yum install -y ntp ntpdate
sudo which date >> $NOMFICHIERLOG
sudo which ntpdate >> $NOMFICHIERLOG
echo " ntpdate 0.us.pool.ntp.org " >> $NOMFICHIERLOG
sudo ntpdate 0.us.pool.ntp.org >> $NOMFICHIERLOG
echo "date après la re-synchronisation [Serveur NTP=$SERVEUR_NTP :]" >> $NOMFICHIERLOG
date >> $NOMFICHIERLOG
# pour re-synchroniser l'horloge matérielle, et ainsi conserver l'heure après un reboot, et ce y compris après et pendant
# une coupure réseau
sudo hwclock --systohc


# prod:
# ./changement-hostname-nom-domaine.sh && ./docker-BARE-METAL-SETUP.sh && ./installation-docker-gitlab.rectte-jibl.sh >> $NOMFICHIERLOG
# usinage:
./docker-BARE-METAL-SETUP.sh && ./installation-docker-gitlab.rectte-jibl.sh && ./configurer-backup-automatique.sh && incrementerCompteurGirofle
# --------------------------------------------------------------------------------------------------------------------------------------------
# Que la lumière soit! (pour activer les changemnts impactés dans [changement-hostname-nom-domaine.sh])

# Pour terminer, on installe les scripts d'opérations standards d'exploitation dans le répertoire girofle
sudo cp -Rf ./operations-std 


clear
echo " +provision+girofle+  TERMINEE - " >> $NOMFICHIERLOG
echo " +provision+girofle+  TERMINEE - "
echo " +provision+girofle+  LOGS:  "
echo "   "
cat $NOMFICHIERLOG
echo "   "
echo " +provision+girofle+  Etats des conteneurs Girofle: "
sudo docker ps -a
echo " +provision+girofle+  Etats des conteneurs Girofle: "
echo "   "

# relancer_reseau
# echo 'exécutez maintenant la commande: [./relancer-reseau.sh]'
# echo 'exécutez maintenant : [sudo systemctl restart network]'

