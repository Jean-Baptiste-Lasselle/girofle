# Installation de Docker sur centos 7
																						
# update CentOS 7
sudo yum clean all -y && sudo yum update -y

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							ENV								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
export ADRESSE_IP_SRV_GITLAB
export NOMFICHIERLOG="$(pwd)/provision-girofle.log"
rm -f $NOMFICHIERLOG
touch $NOMFICHIERLOG
# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							FONCTIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------

demander_addrIP () {

	echo "Quelle adresse IP souhaitez-vous que l'instance gitlab utilise?"
	echo "Cette adresse est à  choisir parmi:"
	echo " "
	ip addr|grep "inet"|grep -v "inet6"|grep "enp\|wlan"
	echo " "
	read ADRESSE_IP_CHOISIE
	if [ "x$ADRESSE_IP_CHOISIE" = "x" ]; then
       ADRESSE_IP_CHOISIE=0.0.0.0
	fi
	
	ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_CHOISIE
	echo " Binding Adresse IP choisit pour le serveur gitlab: $ADRESSE_IP_CHOISIE";
}


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							OPS								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------

echo " provision-girofle-  COMMENCEE  - " >> $NOMFICHIERLOG
# On rend exécutables 
sudo chmod +x ./docker-EASE-SPACE-BARE-METAL-SETUP.sh
sudo chmod +x ./installation-docker-gitlab.rectte-jibl.sh
sudo chmod +x ./changement-hostname-nom-domaine.sh
sudo chmod +x ./configurer-backup-automatique.sh
# On s'assure de l'adresse IP à utiliser (par l'instance Gitlab)
demander_addrIP
# On change config hostname/nomdomaine pour adopter girofle
./changement-hostname-nom-domaine.sh
# prod:
# ./changement-hostname-nom-domaine.sh && ./docker-EASE-SPACE-BARE-METAL-SETUP.sh && ./installation-docker-gitlab.rectte-jibl.sh >> $NOMFICHIERLOG
# usinage:
./docker-EASE-SPACE-BARE-METAL-SETUP.sh && ./installation-docker-gitlab.rectte-jibl.sh && ./configurer-backup-automatique.sh
# --------------------------------------------------------------------------------------------------------------------------------------------
# Que la lumière soit! (pour activer les changemnts impactés dans [changement-hostname-nom-domaine.sh])
sudo systemctl restart network >> $NOMFICHIERLOG
echo " provision-girofle-  TERMINEE - " >> $NOMFICHIERLOG
