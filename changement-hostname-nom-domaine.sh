# Installation de Docker sur Centos 7

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							ENV								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# - Variables d'environnement héritées de "operations.sh":
#                >>>   export ADRESSE_IP_SRV_GITLAB
#                >>>   export NOMFICHIERLOG="$(pwd)/provision-girofle.log"
# --------------------------------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------------------------------------
#														RESEAU-HOTE-DOCKER																	 #
# --------------------------------------------------------------------------------------------------------------------------------------------
# [SEGMENT-IP alloués par DHCP bytes: 192.168.1.123 => 192.168.1.153]
# ADRESSE_IP_LINUX_NET_INTERFACE_1=192.168.1.123
# ADRESSE_IP_LINUX_NET_INTERFACE_2=192.168.1.124
# ADRESSE_IP_LINUX_NET_INTERFACE_3=192.168.1.125
# ADRESSE_IP_LINUX_NET_INTERFACE_4=192.168.1.126
# --------------------------------------------------------------------------------------------------------------------------------------------

# ---------------------------------------
# - répertoires  dans l'hôte docker
# ---------------------------------------
export REP_GESTION_CONTENEURS_DOCKER=/conteneurs-docker
##############################################################################################################################################


# - le fichier "/etc/hostname" ne doit contenir que la seule ligne suivante:
# "$ADRESSE_IP_SRV_GITLAB   archiveur-prj-pms.io"
sudo rm -f /etc/hostname
rm -f  ./nouveau.fichier.hostname
echo "$ADRESSE_IP_SRV_GITLAB   archiveur-prj-pms.io" >> ./nouveau.fichier.hostname
sudo cp -f ./nouveau.fichier.hostname /etc/hostname
rm -f ./nouveau.fichier.hostname
# - exécuter (pour "activer" le hostname...):
sudo hostname -F /etc/hostname
# - à ajouter en fin de fichier "/etc/hosts":
# "$ADRESSE_IP_SRV_GITLAB   archiveur-prj-pms.io"
rm -f ./nouveau.fichier.hosts
sudo echo "$ADRESSE_IP_SRV_GITLAB   archiveur-prj-pms.io" >> ./nouveau.fichier.hosts
sudo cat /etc/hosts  >> ./nouveau.fichier.hosts
sudo rm -f /etc/hosts
sudo cp -f ./nouveau.fichier.hosts /etc/hosts
rm -f ./nouveau.fichier.hosts
# sudo echo "$ADRESSE_IP_SRV_GITLAB   archiveur-prj-pms.io" >> /etc/hosts



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
# archiveur-prj-pms.io
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
# export NOMDHOTE=archiveur-prj-pms.io
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


