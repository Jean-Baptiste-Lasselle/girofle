# Installation de Docker sur centos 7
																						
# update CentOS 7
sudo yum clean all -y && sudo yum update -y

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
sudo systemctl restart network
# echo 'exécutez maintenant : [sudo systemctl restart network]'

}

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							OPS								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# export UTILISATEUR_LINUX_GIROFLE
# # UTILISATEUR_LINUX_GIROFLE=girofle
# UTILISATEUR_LINUX_GIROFLE=$UTILISATEUR_LINUX_GIROFLE

echo " provision-girofle-  -------------------------------------" >> $NOMFICHIERLOG
echo " provision-girofle-  RELANCEMENT DU SERVICE RESEAU - DEBUT" >> $NOMFICHIERLOG
echo " provision-girofle-  -------------------------------------" >> $NOMFICHIERLOG
relancer_reseau
echo " provision-girofle-  -------------------------------------" >> $NOMFICHIERLOG
echo " provision-girofle-  RELANCEMENT DU SERVICE RESEAU - FIN" >> $NOMFICHIERLOG
echo " provision-girofle-  -------------------------------------" >> $NOMFICHIERLOG
# echo 'exécutez maintenant : [sudo systemctl restart network]'



