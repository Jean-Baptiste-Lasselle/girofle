#!/bin/bash
# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################						ENVIRONNEMENT							######################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# Hérité de [operations.sh]
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
# - Logs de la recette de provision:
# 
# 	--- >>> export NOMFICHIERLOG="$(pwd)/provision-girofle.log"
# 
# - répertoires  dans l'hôte docker:
# 
# 	--- >>> export REPERTOIRE_GIROFLE=/girofle
# 	--- >>> export COMPTEUR_GIROFLE=$REPERTOIRE_GIROFLE/.auto-increment.girofle
# 	--- >>> export INVENTAIRE_GIROFLE=$REPERTOIRE_GIROFLE/inventory.girofle
# 	--- >>> export NOMDEDOMAINE_INSTANCE_GITLAB
# 	--- >>> export ADRESSE_IP_SRV_GITLAB
# 	--- >>> export NO_PORT_IP_SRV_GITLAB
# 	--- >>> export NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST
# 
# 
# 


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################						FONCTIONS								######################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
# 
# 

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++ >>> L'appel de cette fonction implique que l'on re-démarre le réseau en appelant la fonction [relancer_reseau()], comme
#         dernière opération du script [operations.sh]
# 
# systemctl restart networking.service
# 
# +++ >>> TODO:
# 		- refaire la fonction pour qu'elle donne aux 4 interfaces réseaux une condiguration en DHCP non gérée par le NetworkManager: ainsi, on
#         pourra ajouter le hostname derrière sans problème
# 
# +++ >>> Un seul argument : le nom de domaine affecté à chaque interface réseau
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reconfigurer_interfaces_reseau () {

# sudo sed -i 's/NM_CONTROLLED="yes"/NM_CONTROLLED="no"/g' /etc/sysconfig/network-scripts/ifcfg-enp0s*

for fichierconf in $(ls /etc/sysconfig/network-scripts/ifcfg-enp0s*)
do
	if [ "$fichierconf" = "/etc/sysconfig/network-scripts/ifcfg-enp0s3" ]; then
       reconfigurer_interface_reseau $fichierconf "kytes-ssh.io"
	fi
	if [ "$fichierconf" = "/etc/sysconfig/network-scripts/ifcfg-enp0s8" ]; then
       reconfigurer_interface_reseau $fichierconf "kytes-alt1.io"
	fi
	if [ "$fichierconf" = "/etc/sysconfig/network-scripts/ifcfg-enp0s9" ]; then
       reconfigurer_interface_reseau $fichierconf "kytes-alt2.io"
	fi
	if [ "$fichierconf" = "/etc/sysconfig/network-scripts/ifcfg-enp0s10" ]; then
       reconfigurer_interface_reseau $fichierconf "$NOMDEDOMAINE_INSTANCE_GITLAB"
	fi
done

}
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 
# +++ >>> Premier argument : le chemin absolu du fichier de configuration réseau centos associé à l'interface reconfigurée
# 
# +++ >>> Second argument : le nom de domaine à associer à l'interface reconfigurée
# 
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reconfigurer_interface_reseau () {




# sudo sed -i 's/NM_CONTROLLED="yes"/NM_CONTROLLED="no"/g' /etc/sysconfig/network-scripts/ifcfg-enp0s*
FICHIER_CONF_INTERF_RESEAU=$1
NOM_DE_DOMAINE_ASSOCIE=$2
FICHIERCONFRESEAUTEMP=./confreseautemp.girofle
touch $FICHIERCONFRESEAUTEMP
rm -f $FICHIERCONFRESEAUTEMP
echo " +girofle+[reconfigurer_interface_reseau()]+ variable : [FICHIER_CONF_INTERF_RESEAU=$FICHIER_CONF_INTERF_RESEAU]" >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]+ variable : [FICHIERCONFRESEAUTEMP=$FICHIERCONFRESEAUTEMP]" >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]+ variable: [NOM_DE_DOMAINE_ASSOCIE=$NOM_DE_DOMAINE_ASSOCIE]" >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]+ ----------------------------------------- " >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]+ COPIE FICHIER RESEAU SYSTEME HÔTE - DEBUT " >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]+ ----------------------------------------- " >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]+ [ls -all $FICHIERCONFRESEAUTEMP] donne sur le système hôte [AVANT la copie du fichier système] : " >> $NOMFICHIERLOG
ls -all $FICHIERCONFRESEAUTEMP >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]" >> $NOMFICHIERLOG
sudo cp -f $FICHIER_CONF_INTERF_RESEAU $FICHIERCONFRESEAUTEMP
echo " +girofle+[reconfigurer_interface_reseau()]+ [ls -all $FICHIERCONFRESEAUTEMP] donne sur le système hôte [APRES la copie du fichier système] : " >> $NOMFICHIERLOG
ls -all $FICHIERCONFRESEAUTEMP >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]" >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]+ ---------------------------------------- " >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]+ COPIE FICHIER RESEAU SYSTEME HÔTE - FIN  " >> $NOMFICHIERLOG
echo " +girofle+[reconfigurer_interface_reseau()]+ ---------------------------------------- " >> $NOMFICHIERLOG
sudo chown -R $UTILISATEUR_LINUX_GIROFLE:$UTILISATEUR_LINUX_GIROFLE $FICHIERCONFRESEAUTEMP
sudo chmod a-r-w-x   $FICHIERCONFRESEAUTEMP
# pour que le user de provisioning ait les droits en écriture et lecture sur ce fichier temporaire
sudo chmod u+r+w   $FICHIERCONFRESEAUTEMP
sudo chmod g+r   $FICHIERCONFRESEAUTEMP
# =============================================================================================================================================
# 1./ On reconfigure l'interface réseau linux dans le CentOS, afin qu'elle ne soit plus controllée par le Network manager
# =============================================================================================================================================
echo 'NM_CONTROLLED="no"' >> $FICHIERCONFRESEAUTEMP
# =============================================================================================================================================
# 2./ Puis on ajoute la configuration hostname spécifique à l'interface réseau.
# =============================================================================================================================================
echo "HOSTNAME=$NOM_DE_DOMAINE_ASSOCIE" >> $FICHIERCONFRESEAUTEMP
sudo rm -f $FICHIER_CONF_INTERF_RESEAU
sudo cp -f $FICHIERCONFRESEAUTEMP $FICHIER_CONF_INTERF_RESEAU




# pour ne pas accumuler
rm -f $FICHIERCONFRESEAUTEMP


# =============================================================================================================================================
# 3./ Enfin, on redonne les mêmes attributs SGF / PAM que dans tous les systèmes CentOS 7
# =============================================================================================================================================
# 
sudo chown -R root:root $FICHIER_CONF_INTERF_RESEAU
# on enlève tous les droits à tout le monde
sudo chmod a-r-w-x   $FICHIER_CONF_INTERF_RESEAU
# pour ne mette que les exacts droits tels qu'ils sont au commissionning d'un CentOS 7
sudo chmod u+r+w   $FICHIER_CONF_INTERF_RESEAU
sudo chmod g+r   $FICHIER_CONF_INTERF_RESEAU
echo " +girofle+[reconfigurer_interface_reseau()]+ réinitialisation des droits systèmes pour le fichier réseau : $FICHIER_CONF_INTERF_RESEAU" >> $NOMFICHIERLOG

}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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
# 				 # le nom de domaine de l'instance Gitlab et de l'insance gitlab de test
#                >>>   export NOMDEDOMAINE_INSTANCE_GITLAB=prj-pms.girofle.io

# --------------------------------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------------------------------------
#														RESEAU-HOTE-DOCKER																	 #
# --------------------------------------------------------------------------------------------------------------------------------------------
# [SEGMENT-IP alloués par DHCP bytes: 192.168.1.123 => 192.168.1.153]
ADRESSE_IP_LINUX_NET_INTERFACE_1=192.168.1.31
ADRESSE_IP_LINUX_NET_INTERFACE_2=192.168.1.32
ADRESSE_IP_LINUX_NET_INTERFACE_3=192.168.1.33
ADRESSE_IP_LINUX_NET_INTERFACE_4=192.168.1.34
# --------------------------------------------------------------------------------------------------------------------------------------------

##############################################################################################################################################

# 
# - le fichier "/etc/hostname" ne doit contenir que la seule ligne suivante:
# "$ADRESSE_IP_SRV_GITLAB   $NOMDEDOMAINE_INSTANCE_GITLAB"
# sudo rm -f /etc/hostname
# rm -f  ./nouveau.fichier.hostname
# echo "$ADRESSE_IP_SRV_GITLAB   $NOMDEDOMAINE_INSTANCE_GITLAB" >> ./nouveau.fichier.hostname
# echo "$ADRESSE_IP_LINUX_NET_INTERFACE_1    kytes-io-ssh" >> ./nouveau.fichier.hostname
# echo "$ADRESSE_IP_LINUX_NET_INTERFACE_3    kytes-io-alt1" >> ./nouveau.fichier.hostname
# echo "$ADRESSE_IP_LINUX_NET_INTERFACE_4    kytes-io-alt2" >> ./nouveau.fichier.hostname
# ================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Pour configurer un hostname différent pour chaque interface réseau, il faudra éditer les fichiers:
# TODO: revoir tout cela avec [hostnamectl --help]

reconfigurer_interfaces_reseau



# =============================================================================================================================================
# 3./ Puis on configure le hostname principal /etc/hostname
# =============================================================================================================================================
export FICHIERTEMPHOSTNAME=./config-hostname-reseau.girofle
rm -f $FICHIERTEMPHOSTNAME
echo "$NOMDEDOMAINE_INSTANCE_GITLAB" >> $FICHIERTEMPHOSTNAME
sudo rm -f /etc/hostname
sudo cp -f $FICHIERTEMPHOSTNAME /etc/hostname

# hop, et on remet les bons droits sur /etc/hostname
sudo chown -R root:root /etc/hostname
# on enlève tous les droits à tout le monde
sudo chmod a-r-w-x   /etc/hostname
# pour ne mette que les exacts droits tles qu'ils sont au commissionning d'un CentOS 7
sudo chmod u+r+w   /etc/hostname
sudo chmod g+r   /etc/hostname

# et bim, on active le hostname sans re-démarrage
sudo hostname -F /etc/hostname

# =============================================================================================================================================
# 4./ Enfin, on configure les hostnames avec le fichier /etc/hosts
# =============================================================================================================================================

rm -f ./nouveau.fichier.hosts
sudo cat /etc/hosts  >> ./nouveau.fichier.hosts
sudo echo "# Interface réseau utilisée par l'instance Gitlab" >> ./nouveau.fichier.hosts
sudo echo "$ADRESSE_IP_SRV_GITLAB    $NOMDEDOMAINE_INSTANCE_GITLAB" >> ./nouveau.fichier.hosts
echo "$ADRESSE_IP_LINUX_NET_INTERFACE_1    kytes-ssh.io" >> ./nouveau.fichier.hosts
echo "$ADRESSE_IP_LINUX_NET_INTERFACE_3    kytes-alt1.io" >> ./nouveau.fichier.hosts
echo "$ADRESSE_IP_LINUX_NET_INTERFACE_4    kytes-alt2.io" >> ./nouveau.fichier.hosts
sudo rm -f /etc/hosts
sudo cp -f ./nouveau.fichier.hosts /etc/hosts
rm -f ./nouveau.fichier.hosts
# hop, et on remet les bons droits sur /etc/hostname
sudo chown -R root:root /etc/hosts
# on enlève tous les droits à tout le monde
sudo chmod a-r-w-x   /etc/hosts
# pour ne mette que les exacts droits tles qu'ils sont au commissionning d'un CentOS 7
sudo chmod u+r+w   /etc/hosts
sudo chmod g+r   /etc/hosts


# --------------------------------------------------------------------------------------------------------------------------------------------
# -----		Ce qui donne la sortie standard:
# --------------------------------------------------------------------------------------------------------------------------------------------
# [jibl@pc-136 ~]$ sudo vim /etc/hostname
# [sudo] password for jibl:
# sudo: vim: command not found
# [jibl@pc-136 ~]$ sudo vi /etc/hostname
# [jibl@pc-136 ~]$ sudo vi /etc/hostname
# [jibl@pc-136 ~]$ sudo vi /etc/hostname
# [jibl@pc-136 ~]$ sudo hostname -F /etc/hostname
# [jibl@pc-136 ~]$ echo $HOSTNAME
# pc-136.home
# [jibl@pc-136 ~]$ sudo vi /etc/hosts
# [jibl@pc-136 ~]$ echo $HOSTNAME
# pc-136.home
# [jibl@pc-136 ~]$ hostname --short
# archiveur
# [jibl@pc-136 ~]$ hostname --domain
# prj.pms
# [jibl@pc-136 ~]$  hostname --fqdn
# $NOMDEDOMAINE_INSTANCE_GITLAB
# [jibl@pc-136 ~]$ hostname --ip-address
# 192.168.1.32
# [jibl@pc-136 ~]$
# --------------------------------------------------------------------------------------------------------------------------------------------





# --------------------------------------------------------------------------------------------------------------------------------------------
# Installation de l'instance gitlab dans un conteneur, à partir de l'image officielle :
# https://docs.gitlab.com/omnibus/docker/README.html
# --------------------------------------------------------------------------------------------------------------------------------------------
# ce conteneur docker est lié à l'interface réseau d'adresse IP [$ADRESSE_IP_SRV_GITLAB]:
# ==>> Les ports ouverts avec loption --publish seront accessibles uniquement par cette adresse IP
#
# sudo docker run --detach --hostname gitlab.$GITLAB_INSTANCE_NUMBER.kytes.io --publish $ADRESSE_IP_SRV_GITLAB:4433:443 --publish $ADRESSE_IP_SRV_GITLAB:8080:80 --publish 2227:22 --name conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR:$GITLAB_DATA_DIR gitlab/gitlab-ce:latest
# Mais maintenant, j'utilise le nom d'hôte de l'OS, pour régler la question du nom de domaine ppour accéder à l'instance gitlab en mode Web.
# export NOMDHOTE=$NOMDEDOMAINE_INSTANCE_GITLAB
# sudo docker run --detach --hostname $HOSTNAME --publish $ADRESSE_IP_SRV_GITLAB:433:443 --publish $ADRESSE_IP_SRV_GITLAB:80:80 --publish 2227:22 --name conteneur-kytes.io.gitlab.$GITLAB_INSTANCE_NUMBER --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR:$GITLAB_DATA_DIR gitlab/gitlab-ce:latest



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


