
# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################						DESCRIPTION							##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
# Ce script permet d'envoyr sur la sortie standard, la liste des noms d'instances gitlab en cours d'éxécution.
# 
# Cette liste présente, pour chaque instance Gitlab:
# 
# 		==>> son nom (choisit par l'utilisateur au départ, n'a pas besoin d'être unique)
# 		==>> son numéro d'instance (attrbué par le script de création d'une novelle instance gitlab)
# 		==>> 
# 
# 
# 
# 

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
# pour l'auto-incrémentation: à chaque fois qu'une nouvelle instance est créée avec succès, une nouvelle ligne est ajoutée dans ce fichier
export COMPTEUR_GIROFLE=$REP_GESTION_CONTENEURS_DOCKER/.auto-increment.girofle
# à remplacer par une petite bdd embarquée de type nosql, .h2, pour au moins avoir gestion des accès concconcurrents, et enfin à remplacer par [etcd]
export INVENTAIRE_GIROFLE=$REP_GESTION_CONTENEURS_DOCKER/inventory.girofle
# le numéro de port IP qui sera utilisé par le connecteur HTTP de l'instance Gitlab
export ADRESSE_IP_SRV_GITLAB
# l'adresse IP qui sera utilisée par les connecteurs HTTP/HTTPS de l'instance Gitlab
export NO_PORT_IP_SRV_GITLAB
export NOMFICHIERLOG="$(pwd)/provision-girofle.log"
# rm -f $NOMFICHIERLOG
# touch $NOMFICHIERLOG
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
# TODO: modifier car le fichier $INVENTAIRE_GIROFLE
echo " +girofle+  INVENTORY STARTS HERE" >> $NOMFICHIERLOG
echo " +girofle+  INSTANCES : " >> $NOMFICHIERLOG
cat $INVENTAIRE_GIROFLE
cat $INVENTAIRE_GIROFLE >> $NOMFICHIERLOG
echo " +girofle+  INVENTORY STOPS HERE" >> $NOMFICHIERLOG