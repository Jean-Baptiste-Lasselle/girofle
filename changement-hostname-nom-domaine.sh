# Installation de Docker sur Centos 7

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################						FONCTIONS								######################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
# 
# 

# 

# +++ >>> L'appel de cette fonction implique que l'on re-démarre le réseau ... (ou plus tard en fin d'opérations...)
# 
# systemctl restart networking.service
# 
# +++ >>> TODO:
# 		- refaire la fonction pour qu'elle donne aux 4 interfaces réseaux une condiguration en DHCP non gérée par le NetworkManager: ainsi, on pourra ajouter le hostname derrière sans problème
# 
# 
reconfigurer_interfaces_reseau () {

# sudo sed -i 's/NM_CONTROLLED="yes"/NM_CONTROLLED="no"/g' /etc/sysconfig/network-scripts/ifcfg-enp0s*
FICHIERCONFRESEAUTEMP=confreseautemp.girofle
rm -f $FICHIERCONFRESEAUTEMP
for fichierconf in $(ls /etc/sysconfig/network-scripts/ifcfg-enp0s*)
do
# echo " FICHIER: /etc/sysconfig/network-scripts/$fichierconf"
# ll $fichierconf
# echo " "
cat $fichierconf >> $FICHIERCONFRESEAUTEMP
echo 'NM_CONTROLLED="no"' >> $FICHIERCONFRESEAUTEMP
sudo rm -f $fichierconf
sudo cp -f $FICHIERCONFRESEAUTEMP $fichierconf
# et on redonne les mêmes attributs SGF / PAM que dans tous les systèmes CentOS 7
sudo chown -R root:root $fichierconf
# on enlève tous les droits à tout le monde
sudo chmod a-r-w-x   $fichierconf
# pour ne mette que les exacts droits tles qu'ils sont au commissionning d'un CentOS 7
sudo chmod u+r+w   $fichierconf
sudo chmod g+w   $fichierconf

# pour ne pas accumuler
rm -f $FICHIERCONFRESEAUTEMP

done



# comment obtenir la liste des interfaces réseaux, pour les re-démarrer
ip addr >> ./listeinterfaces
LISTE_NOMS_INTERFACES=$(awk  -F':' '/enp0s*/ {print $2; echo "okok"}' ./listeinterfaces|awk  -F':' '/enp0s*/ {print $1}'|awk '/enp0s*/ {$1=$1;print}')

for NOM_INTERFACE_RESEAU in $LISTE_NOMS_INTERFACES
do
sudo ip addr flush $NOM_INTERFACE_RESEAU
# echo "reconfiguration: $NOM_INTERFACE_RESEAU"
done

# +++ >>> L'appel de cette fonction implique que l'on re-démarre le réseau ... (ou plus tard en fin d'opérations...)
# systemctl restart networking.service
}

# quelques commades qui pourront être utile pour aider Girofle à palper un système réseau
beaware-girofle () {
# VAR.
# ----

NOM_INTERFACE_RESEAU_A_RECONFIGURER_PAR_DEFAUT=enp0s3 # celle-là, il faut qu'elle passe au niveau opérations
NOM_INTERFACE_RESEAU_A_RECONFIGURER=$NOM_INTERFACE_RESEAU_A_RECONFIGURER_PAR_DEFAUT

# Gestion des valeurs passées en paramètre
# ----------------------------------------

NBARGS=$#
clear
if [ $NBARGS -eq 0 ]
then
	echo "Quel est le nom de l'interface réseau linux que vous souhaitez reconfigurer?"
	echo "(l'interface utilisée par défaut sera : [$NOM_INTERFACE_RESEAU_A_RECONFIGURER]"
	read SAISIE_UTILISATEUR
else
	NOM_INTERFACE_RESEAU_A_RECONFIGURER=$1
fi

if [ "x$SAISIE_UTILISATEUR" = "x" ]
then
	echo "on laisse la valeur par défaut"
else
	NOM_INTERFACE_RESEAU_A_RECONFIGURER=$SAISIE_UTILISATEUR
fi

# confirmation nom interface réseau linux à reconfigurer 
clear
echo "Vous confirmez vouloir re-configurer l'interface réseau linux : [$NOM_INTERFACE_RESEAU_A_RECONFIGURER] ?"
echo "Répondez par Oui ou Non (o/n). Répondre Non annulera toute configuration réseau."
read VOUSCONFIRMEZ
case "$VOUSCONFIRMEZ" in
	[oO] | [oO][uU][iI]) echo "L'interface réseau [$NOM_INTERFACE_RESEAU_A_RECONFIGURER] sera re-configurée" ;;
	[nN] | [nN][oO][nN]) echo "Aucune reconfiguration réseau ne sera faite.";return ;;
esac


# re-spawning de l'interface réseau linux...
ip addr flush $NOM_INTERFACE_RESEAU_A_RECONFIGURER
systemctl restart network

ADRESSE_IP_SRV_JEE=$FUTURE_ADRESSE_IP

}
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
ADRESSE_IP_LINUX_NET_INTERFACE_1=192.168.1.31
ADRESSE_IP_LINUX_NET_INTERFACE_2=192.168.1.32
ADRESSE_IP_LINUX_NET_INTERFACE_3=192.168.1.33
ADRESSE_IP_LINUX_NET_INTERFACE_4=192.168.1.34
# --------------------------------------------------------------------------------------------------------------------------------------------

# ---------------------------------------
# - répertoires  dans l'hôte docker
# ---------------------------------------
export REP_GESTION_CONTENEURS_DOCKER=/girofle
##############################################################################################################################################

export NOMDEDOMAINE=prj-pms.girofle.io
# - le fichier "/etc/hostname" ne doit contenir que la seule ligne suivante:
# "$ADRESSE_IP_SRV_GITLAB   $NOMDEDOMAINE"
# sudo rm -f /etc/hostname
# rm -f  ./nouveau.fichier.hostname
# echo "$ADRESSE_IP_SRV_GITLAB   $NOMDEDOMAINE" >> ./nouveau.fichier.hostname
# echo "$ADRESSE_IP_LINUX_NET_INTERFACE_1    kytes-io-ssh" >> ./nouveau.fichier.hostname
# echo "$ADRESSE_IP_LINUX_NET_INTERFACE_3    kytes-io-alt1" >> ./nouveau.fichier.hostname
# echo "$ADRESSE_IP_LINUX_NET_INTERFACE_4    kytes-io-alt2" >> ./nouveau.fichier.hostname
# ================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Pour configurer un hostname différent pour chaque interface réseau, il faudra éditer les fichiers:
# 
# ================================================
# On commence par reconfiurer les interfaces réseau linux dans le CentOS, afin qu'elles ne soient plus controllées par le Network manager
reconfigurer_interfaces_reseau
# ================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 	> /etc/sysconfig/network-scripts/ifcfg-enp0s3
export FICHIERTEMP=./config-int-reseau.girofle

rm -f $FICHIERTEMP
cat /etc/sysconfig/network-scripts/ifcfg-enp0s3 >> $FICHIERTEMP
echo "$ADRESSE_IP_LINUX_NET_INTERFACE_1    kytes-ssh.io" >> $FICHIERTEMP
sudo rm -f /etc/sysconfig/network-scripts/ifcfg-enp0s3

# ================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 	> /etc/sysconfig/network-scripts/ifcfg-enp0s8
echo "$ADRESSE_IP_LINUX_NET_INTERFACE_3    kytes-alt2.io" >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
# ================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 	> /etc/sysconfig/network-scripts/ifcfg-enp0s9
echo "$ADRESSE_IP_LINUX_NET_INTERFACE_4    kytes-alt2.io" >> /etc/sysconfig/network-scripts/ifcfg-enp0s9
# ================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 	> /etc/sysconfig/network-scripts/ifcfg-enp0s10
echo "$ADRESSE_IP_SRV_GITLAB    $NOMDEDOMAINE" >> /etc/sysconfig/network-scripts/ifcfg-enp0s10

# sudo cp -f ./nouveau.fichier.hostname /etc/hostname
# rm -f ./nouveau.fichier.hostname
# - exécuter (pour "activer" le fichier hostname...):
# sudo hostname -F /etc/hostname
# - à ajouter en fin de fichier "/etc/hosts":
# "$ADRESSE_IP_SRV_GITLAB   $NOMDEDOMAINE"
rm -f ./nouveau.fichier.hosts
sudo cat /etc/hosts  >> ./nouveau.fichier.hosts
sudo echo "$ADRESSE_IP_SRV_GITLAB    $NOMDEDOMAINE" >> ./nouveau.fichier.hosts
# echo "$ADRESSE_IP_LINUX_NET_INTERFACE_1    kytes-ssh.io" >> ./nouveau.fichier.hosts
# echo "$ADRESSE_IP_LINUX_NET_INTERFACE_3    kytes-alt1.io" >> ./nouveau.fichier.hosts
# echo "$ADRESSE_IP_LINUX_NET_INTERFACE_4    kytes-alt2.io" >> ./nouveau.fichier.hosts
sudo rm -f /etc/hosts
sudo cp -f ./nouveau.fichier.hosts /etc/hosts
rm -f ./nouveau.fichier.hosts
# sudo echo "$ADRESSE_IP_SRV_GITLAB   $NOMDEDOMAINE" >> /etc/hosts



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
# $NOMDEDOMAINE
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
# export NOMDHOTE=$NOMDEDOMAINE
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


