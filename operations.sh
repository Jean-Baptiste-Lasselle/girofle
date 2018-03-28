# Installation de Docker sur centos 7
																						
# update CentOS 7
sudo yum clean all -y && sudo yum update -y

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							ENV								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# le numéro de port IP qui sera utilisé par le connecteur HTTP de l'instance Gitlab
export ADRESSE_IP_SRV_GITLAB
# l'adresse IP qui sera utilisée par les connecteurs HTTP/HTTPS de l'instance Gitlab
export NO_PORT_IP_SRV_GITLAB
export NOMFICHIERLOG="$(pwd)/provision-girofle.log"
rm -f $NOMFICHIERLOG
touch $NOMFICHIERLOG
# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							FONCTIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander iteractivement à l'utilisateur du
# script, quelle est l'adresse IP, dans l'hôte Docker, que l'instance Gitlab pourra utiliser
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
# Cette fonction permet de demander iteractivement à l'utilisateur du
# script, quel numéro de port IP, que l'instance Gitlab pourra utiliser dans l'hôte Docker
demander_noPortIP () {

	echo "Quelle adresse IP souhaitez-vous que l'instance gitlab utilise?"
	echo "Cette adresse est à  choisir parmi:"
	echo " "
	ip addr|grep "inet"|grep -v "inet6"|grep "enp\|wlan"
	echo " "
	read NO_PORT_IP_CHOISIT
	if [ "x$NO_PORT_IP_CHOISIT" = "x" ]; then
       NO_PORT_IP_CHOISIT=80
	fi
	
	NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_CHOISIT
	echo " Binding Adresse IP choisit pour le serveur gitlab: $NO_PORT_IP_CHOISIT";
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
demander_noPortIP
# On change config hostname/nomdomaine pour adopter girofle
./changement-hostname-nom-domaine.sh
# prod:
# ./changement-hostname-nom-domaine.sh && ./docker-EASE-SPACE-BARE-METAL-SETUP.sh && ./installation-docker-gitlab.rectte-jibl.sh >> $NOMFICHIERLOG
# usinage:
./docker-EASE-SPACE-BARE-METAL-SETUP.sh && ./installation-docker-gitlab.rectte-jibl.sh && ./configurer-backup-automatique.sh
# --------------------------------------------------------------------------------------------------------------------------------------------
# Que la lumière soit! (pour activer les changemnts impactés dans [changement-hostname-nom-domaine.sh])

echo " provision-girofle-  TERMINEE - " >> $NOMFICHIERLOG
relancer_reseau

