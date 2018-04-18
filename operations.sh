

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
export NOMDEDOMAINE_INSTANCE_GITLAB=prj-pms.girofle.io
# l'adresse IP qui sera utilisée par les connecteurs HTTP/HTTPS de l'instance Gitlab
export ADRESSE_IP_SRV_GITLAB
# le numéro de port IP qui sera utilisé par le connecteur HTTP de l'instance Gitlab
export NO_PORT_IP_SRV_GITLAB
# le numéro de port IP qui sera utilisé par le connecteur HTTP de l'instance Gitlab de test
export NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST


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

	echo "Quel numéro de port IP souhaitez-vous que l'instance gitlab utilise?"
	echo "Ce numéro de port doit être compris entre 1000 et 65535, et ne  pas être dans la liste suivante:"
	# echo " TODO: afficher la liste des numéros de ports utilisés"
	echo " "
	more $INVENTAIRE_GIROFLE
	echo " "
	read NO_PORT_IP_CHOISIT
	if [ "x$NO_PORT_IP_CHOISIT" = "x" ]; then
       NO_PORT_IP_CHOISIT=80
	fi
	
	NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_CHOISIT
	echo " Binding Adresse IP choisit pour le serveur gitlab: $NO_PORT_IP_CHOISIT";
}

# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quel numéro de port IP, la seconde instance Gitlab de Test pourra utiliser dans l'hôte Docker
demander_noPortIP_InstanceTest () {

	echo "À l'adresse IP [$ADRESSE_IP_SRV_GITLAB], quel numéro de port IP souhaitez-vous que l'instance gitlab TEST utilise?"
	echo "Vous devez choisir un numéro de port, par exemple entre 2000 et 60 000, différent du numéro "
	echo "de port utilisé par l'instance Gitlab provisionnée en même temps: [$NO_PORT_IP_SRV_GITLAB]"
	echo " "
	read NO_PORT_IP_CHOISIT
	if [ "x$NO_PORT_IP_CHOISIT" = "x" ]; then
       NO_PORT_IP_CHOISIT=8880
	fi
	
	NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_CHOISIT
	echo " Binding Adresse IP choisit pour le serveur gitlab de tests: $NO_PORT_IP_CHOISIT";
}
# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quel nom de domaine il souhaite utilsier pour l'accès aux instances Gitlab de Girofle.
demander_nomDomaineSouhaite () {

	echo "Quel nom de domaine souhaitez-vous que l'instance gitlab provisionnée à l'installation de Girofle utilise?"
	echo "(Appuyez simpmlement sur la touche entrée pour appliquer la valeur par défaut: [girofle.io]) "
	echo " "
	read NOM_DOMAINE_CHOISIT
	if [ "x$NOM_DOMAINE_CHOISIT" = "x" ]; then
       NOM_DOMAINE_CHOISIT=girofle.io
	fi
	NOMDEDOMAINE_INSTANCE_GITLAB=$NOM_DOMAINE_CHOISIT
	echo "  Binding Adresse IP choisit pour le serveur gitlab de tests: $NOM_DOMAINE_CHOISIT" >> $NOMFICHIERLOG
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
echo " provision-girofle-  COMMENCEE  - " >> $NOMFICHIERLOG
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
sudo chmod +x ./docker-EASE-SPACE-BARE-METAL-SETUP.sh
sudo chmod +x ./installation-docker-gitlab.rectte-jibl.sh
sudo chmod +x ./changement-hostname-nom-domaine.sh
sudo chmod +x ./configurer-backup-automatique.sh
sudo chmod +x ./relancer-reseau.sh
# On s'assure de l'adresse et du numéro de port IP qui seront utilisés (par l'instance Gitlab qui sera créée)
demander_nomDomaineSouhaite
demander_addrIP
demander_noPortIP
demander_noPortIP_InstanceTest

# update CentOS 7
sudo yum clean all -y && sudo yum update -y

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
sudo yum remove -y NetworkManager

# On change config hostname/nomdomaine pour adopter girofle
./changement-hostname-nom-domaine.sh

# echo "PAUSE DEBUG - CONFIG RESEAU - AVANT RELANCE RESEAU "
# read DEBUG

./relancer-reseau.sh

# echo "PAUSE DEBUG - CONFIG RESEAU - APRES RELANCE RESEAU "
# read DEBUG


# prod:
# ./changement-hostname-nom-domaine.sh && ./docker-EASE-SPACE-BARE-METAL-SETUP.sh && ./installation-docker-gitlab.rectte-jibl.sh >> $NOMFICHIERLOG
# usinage:
./docker-EASE-SPACE-BARE-METAL-SETUP.sh && ./installation-docker-gitlab.rectte-jibl.sh && ./configurer-backup-automatique.sh && incrementerCompteurGirofle
# --------------------------------------------------------------------------------------------------------------------------------------------
# Que la lumière soit! (pour activer les changemnts impactés dans [changement-hostname-nom-domaine.sh])

# Pour terminer, on installe les scripts d'opérations standards d'exploitation dans le répertoire girofle
sudo cp -Rf ./operations-std 


clear
echo " provision-girofle-  TERMINEE - " >> $NOMFICHIERLOG
echo " provision-girofle-  TERMINEE - "
echo " provision-girofle-  LOGS:  "
echo "   "
cat $NOMFICHIERLOG
echo "   "
echo " provision-girofle-  Etats des conteneurs Girofle: "
sudo docker ps -a
echo " provision-girofle-  Etats des conteneurs Girofle: "
echo "   "

# relancer_reseau
# echo 'exécutez maintenant la commande: [./relancer-reseau.sh]'
# echo 'exécutez maintenant : [sudo systemctl restart network]'

