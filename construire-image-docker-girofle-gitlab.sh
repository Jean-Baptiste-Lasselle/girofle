# Installation de Docker sur centos 7

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
# 				 # le nom de l'image release officielle de Gitlab, utilisée pour construire $NOM_IMAGE_DOCKER_INSTANCES_GIROFLE
#                >>>   export VERSION_IMAGE_OFFICIELLE_DOCKER_GITLAB=gitlab/gitlab-ce:latest
# 				 # le nom de l'image docker girofle gitlab, construiite sur la base de la release officielle de Gitlab, $VERSION_IMAGE_OFFICIELLE_DOCKER_GITLAB
#                >>>   export NOM_IMAGE_DOCKER_INSTANCES_GIROFLE=girolfe.io/image-gitlab:v1.0.0
# --------------------------------------------------------------------------------------------------------------------------------------------
# export ADRESSE_IP_SRV_GITLAB
# à priori, Girofle n'impose pas que le fichier Dockerfile soit présent dans e répertoire qui constituera le contexte du build docker. On pourra ainsi embarquer dans le repo Git de cette recette, un répertoire contenant lui-même des répertoires, chacun de ces derniers pouvant versionner un contexte de build différent, comme des "blends"
export CONTEXTE_DU_BUILD_DOCKER=./girofle-docker-blends/build-contexts # le répertoire contenant le catalogue de contetes de builds docker pour l'image de base des instances Gitlab.

export DOCKERFILE_INSTANCES_GITLAB=./instances.girofle.dockerfile

##########################################################################################
##########################################################################################
#						IMAGE DOCKER DES INSTANCES GIROFLE/GITLAB				   		 #
##########################################################################################
##########################################################################################
# 
# Ajout du dockerfile
# 
#    =>>> CEPENDANT, lorsque l'on devra comissionner un conteneur gitlab, on 
#         devra "attendre", nécessairement, et en totu cas il est certain que l'on voudra 
#         pouvoir vérifier QUAND une isntacne gitlab est "prête": lorsqu'elle est 
#         dans l'état "healthy".
# 
# 		
#    =>>> CEPENDANT, lorsque l'on devra comissionner un conteneur gitlab, on devra 
#         "attendre", nécessairement, et en totu cas il est certain que l'on voudra 
#         pouvoir vérifier QUAND une isntacne gitlab est "prête": lorsqu'elle est dans 
#         l'état "healthy". J'utiliserai donc la fonctionnalité "HEALTHCHECK" de docker 
# 
# 		
# 
# 
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ---------	DEBUT GENERATION IMAGE DOCKER DES INSTANCES GITLAB GIROFLE   ---- " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG

# - Génération du répertoire  $CONTEXTE_DU_BUILD_DOCKER
rm -rf $CONTEXTE_DU_BUILD_DOCKER
mkdir -p $CONTEXTE_DU_BUILD_DOCKER
# - Génération du fichier $DOCKERFILE_INSTANCES_GITLAB
sudo rm -f $DOCKERFILE_INSTANCES_GITLAB

echo "FROM $VERSION_IMAGE_OFFICIELLE_DOCKER_GITLAB" >> $DOCKERFILE_INSTANCES_GITLAB
echo "LABEL name=\"gitlab.girofle.io\" \\" >> $DOCKERFILE_INSTANCES_GITLAB
echo "   vendor=\"kytes.io\" \\" >> $DOCKERFILE_INSTANCES_GITLAB
echo "   license=\"GPLv2\" \\" >> $DOCKERFILE_INSTANCES_GITLAB
DATEDEMONBUILD=`date +"%M/%d/%Y %Hh%Mmin%Ssec"`
echo "   build-date=\"$DATEDEMONBUILD\" " >> $DOCKERFILE_INSTANCES_GITLAB
# echo "RUN apt-get remove -y libappstream3 && apt-get update -y" >> $DOCKERFILE_INSTANCES_GITLAB
echo "RUN apt-get update -y" >> $DOCKERFILE_INSTANCES_GITLAB
# echo "RUN rm -f ./etc.gitlab.rb.girofle" >> $DOCKERFILE_INSTANCES_GITLAB
# echo "RUN cp /etc/gitlab/gitlab.rb ./etc.gitlab.rb.girofle" >> $DOCKERFILE_INSTANCES_GITLAB
# echo "RUN sed -i \"s/# external_url 'GENERATED_EXTERNAL_URL'/external_url \\\"http:\\/\\/$NOMDEDOMAINE_INSTANCE_GITLAB:$NO_PORT_IP_SRV_GITLAB\\\"/g\" ./etc.gitlab.rb.girofle" >> $DOCKERFILE_INSTANCES_GITLAB
# echo "RUN rm -f /etc/gitlab/gitlab.rb" >> $DOCKERFILE_INSTANCES_GITLAB
# echo "RUN cp -f ./etc.gitlab.rb.girofle /etc/gitlab/gitlab.rb" >> $DOCKERFILE_INSTANCES_GITLAB
# HEALTH_CHECK
# echo "CMD [\"/usr/local/bin/wrapper\"]" >> $DOCKERFILE_INSTANCES_GITLAB
# Les 2 HEALTH_CHECK distincts permettent de discriminer les échecs causés par
# la configuration réseau / DNS  de la cible de déploiement. Ils devront être refactorisé en un unique agent
# On ne fait donc pas de vérification de la configuration dNS? on passe uniquement par adresse IP pour le HEALTH_CHECK unique
echo "HEALTHCHECK --interval=1s --timeout=300s --start-period=1s --retries=300 CMD curl --fail http://$ADRESSE_IP_SRV_GITLAB:$NO_PORT_IP_SRV_GITLAB/ || exit 1" >> $DOCKERFILE_INSTANCES_GITLAB
# echo "HEALTHCHECK --interval=5m --timeout=3s --start-period=1 --retries=17 CMD curl --fail http://$NOMDEDOMAINE_INSTANCE_GITLAB:$NO_PORT_IP_SRV_GITLAB/ || exit 1" >> $DOCKERFILE_INSTANCES_GITLAB
echo "CMD [\"/usr/local/bin/wrapper\"]" >> $DOCKERFILE_INSTANCES_GITLAB
# echo "CMD [\"/bin/bash\"]" >> $DOCKERFILE_INSTANCES_GITLAB



echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ---------------------	 DOCKERFILE IMAGE GITLAB      ----------------------- " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
cat $DOCKERFILE_INSTANCES_GITLAB >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  [CONTEXTE_DU_BUILD_DOCKER=$CONTEXTE_DU_BUILD_DOCKER] ------------------------- " >> $NOMFICHIERLOG
sudo ls -all $CONTEXTE_DU_BUILD_DOCKER

# ben le build, quoi ...
sudo docker build --tag $NOM_IMAGE_DOCKER_INSTANCES_GIROFLE -f $DOCKERFILE_INSTANCES_GITLAB $CONTEXTE_DU_BUILD_DOCKER | tee $NOMFICHIERLOG

# sudo docker ps -a >> $NOMFICHIERLOG # et voilà la liste des conteneurs docker que tu as créés.


echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  [Liste des images docker présentes localement] ------------------------- " >> $NOMFICHIERLOG
sudo docker images >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ------	FIN GENERATION IMAGE DOCKER DES INSTANCES GITLAB GIROFLE     -------- " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
# ET LE DOCKER RUN







sudo docker run --detach --hostname $NOMDEDOMAINE_INSTANCE_GITLAB --publish $ADRESSE_IP_SRV_GITLAB:433:443 --publish $ADRESSE_IP_SRV_GITLAB:$NO_PORT_IP_SRV_GITLAB:80 --publish $ADRESSE_IP_SRV_GITLAB:2227:22 --name $NOM_DU_CONTENEUR_CREE --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR:$GITLAB_DATA_DIR gitlab/gitlab-ce:latest

# persistance de la nouvelle entrée dans l'inventaire des instances gitlab
# export ENTREE_INVENTAIRE=$(" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_SRV_GITLAB] + [REP_GIROFLE_INSTANCE_GITLAB=$REP_GIROFLE_INSTANCE_GITLAB] + [NOM_DU_CONTENEUR_CREE=$NOM_DU_CONTENEUR_CREE]")
export ENTREE_INVENTAIRE=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB=$NO_PORT_IP_SRV_GITLAB] + [REP_GIROFLE_INSTANCE_GITLAB=$REP_GIROFLE_INSTANCE_GITLAB] + [NOM_DU_CONTENEUR_CREE=$NOM_DU_CONTENEUR_CREE]"
sudo rm -f $INVENTAIRE_GIROFLE.temp
sudo touch $INVENTAIRE_GIROFLE.temp
sudo chown -R $UTILISATEUR_LINUX_GIROFLE:$UTILISATEUR_LINUX_GIROFLE $INVENTAIRE_GIROFLE.temp
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE.temp
sudo chmod u+r+w $INVENTAIRE_GIROFLE.temp
# on garde les entrées précédentes
sudo cat $INVENTAIRE_GIROFLE >> $INVENTAIRE_GIROFLE.temp
# on ajoute la nouvelle entrée
echo $ENTREE_INVENTAIRE >> $INVENTAIRE_GIROFLE.temp
sudo rm -f $INVENTAIRE_GIROFLE
sudo cp -f $INVENTAIRE_GIROFLE.temp $INVENTAIRE_GIROFLE
sudo chown -R $UTILISATEUR_LINUX_GIROFLE:$UTILISATEUR_LINUX_GIROFLE $INVENTAIRE_GIROFLE
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE
sudo chmod u+r+w $INVENTAIRE_GIROFLE

##########################################################################################
#			configuration du nom de domaine pour l'accès à l'instance gitlab   		   	 #  
##########################################################################################

sudo rm -f ./etc.gitlab.rb.girofle
sudo docker cp $NOM_DU_CONTENEUR_CREE:/etc/gitlab/gitlab.rb ./etc.gitlab.rb.girofle

# sed -i 's/external_url "*"/external_url "http://$HOSTNAME:$NO_PORT_IP_SRV_GITLAB"/g' ./etc.gitlab.rb.recup.jibl

sudo sed -i "s/# external_url 'GENERATED_EXTERNAL_URL'/external_url \"http:\/\/$NOMDEDOMAINE_INSTANCE_GITLAB:$NO_PORT_IP_SRV_GITLAB\"/g" ./etc.gitlab.rb.girofle

echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  Instance Gitlab provisionnée à l'installation Girofle - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  Contenu [./etc.gitlab.rb.girofle] APRES SUBSTITUTION : - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  DEBUT [./etc.gitlab.rb.girofle] - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
cat ./etc.gitlab.rb.girofle >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  FIN   [./etc.gitlab.rb.girofle] - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG

sudo docker cp ./etc.gitlab.rb.girofle $NOM_DU_CONTENEUR_CREE:./etc.gitlab.rb.girofle
sudo docker exec -it $NOM_DU_CONTENEUR_CREE /bin/bash -c "rm -f /etc/gitlab/gitlab.rb"
sudo docker exec -it $NOM_DU_CONTENEUR_CREE /bin/bash -c "cp -f ./etc.gitlab.rb.girofle /etc/gitlab/gitlab.rb"
sudo docker exec -it $NOM_DU_CONTENEUR_CREE /bin/bash -c "rm -f ./etc.gitlab.rb.girofle"
# sudo docker restart $NOM_DU_CONTENEUR_CREE
# à la place d'un redémarrage complet du conteneur, j'utilise [gitlab-ctl]
sudo docker exec -it $NOM_DU_CONTENEUR_CREE /bin/bash -c "gitlab-ctl reconfigure"
sudo rm -f ./etc.gitlab.rb.girofle


##########################################################################################
##########################################################################################
#						instance supplémentaire de test						   		   	 #
##########################################################################################
##########################################################################################
# 
sudo docker run --detach --hostname $NOMDEDOMAINE_INSTANCE_GITLAB --publish $ADRESSE_IP_SRV_GITLAB:4433:443 --publish $ADRESSE_IP_SRV_GITLAB:$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST:80 --publish $ADRESSE_IP_SRV_GITLAB:2277:22 --name $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST --restart always --volume $CONTENEUR_GITLAB_MAPPING_HOTE_CONFIG_DIR2:$GITLAB_CONFIG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_LOG_DIR2:$GITLAB_LOG_DIR --volume $CONTENEUR_GITLAB_MAPPING_HOTE_DATA_DIR2:$GITLAB_DATA_DIR gitlab/gitlab-ce:latest

# persistance de la nouvelle entrée dans l'inventaire des instances gitlab
# ENTREE_INVENTAIRE=$(" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] + [REP_GIROFLE_INSTANCE_GITLAB_SUPPLEMENTAIRE_POUR_TEST=$REP_GIROFLE_INSTANCE_GITLAB_SUPPLEMENTAIRE_POUR_TEST] + [NOM_DU_CONTENEUR_CREE=$NOM_DU_CONTENEUR_CREE]")
ENTREE_INVENTAIRE=" +girofle+ INSTANCE GITLAB no. [$GITLAB_INSTANCE_NUMBER] + [ADRESSE_IP_SRV_GITLAB=$ADRESSE_IP_SRV_GITLAB] +[NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST=$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST] + [REP_GIROFLE_INSTANCE_GITLAB_SUPPLEMENTAIRE_POUR_TEST=$REP_GIROFLE_INSTANCE_GITLAB_SUPPLEMENTAIRE_POUR_TEST] + [NOM_DU_CONTENEUR_CREE=$NOM_DU_CONTENEUR_CREE]"
sudo rm -f $INVENTAIRE_GIROFLE.temp
touch $INVENTAIRE_GIROFLE.temp
sudo chown -R $UTILISATEUR_LINUX_GIROFLE:$UTILISATEUR_LINUX_GIROFLE $INVENTAIRE_GIROFLE.temp
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE.temp
sudo chmod u+r+w $INVENTAIRE_GIROFLE.temp
# on garde les entrées précédentes
sudo cat $INVENTAIRE_GIROFLE >> $INVENTAIRE_GIROFLE.temp
# on ajoute la nouvelle entrée
echo $ENTREE_INVENTAIRE >> $INVENTAIRE_GIROFLE.temp
sudo rm -f $INVENTAIRE_GIROFLE
sudo cp -f $INVENTAIRE_GIROFLE.temp $INVENTAIRE_GIROFLE
sudo chown -R $UTILISATEUR_LINUX_GIROFLE:$UTILISATEUR_LINUX_GIROFLE $INVENTAIRE_GIROFLE
sudo chmod a-r-w-x $INVENTAIRE_GIROFLE
sudo chmod u+r+w $INVENTAIRE_GIROFLE

##########################################################################################
#			configuration du nom de domaine pour l'accès à l'instance gitlab   		   	 #
#							supplémentaire pour les test		   		   	 			 #
##########################################################################################

sudo rm -f ./etc.gitlab.rb.girofle
sudo docker cp $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST:/etc/gitlab/gitlab.rb ./etc.gitlab.rb.girofle

# sed -i 's/external_url "*"/external_url "http://$HOSTNAME:$NO_PORT_IP_SRV_GITLAB"/g' ./etc.gitlab.rb.recup.jibl

sudo sed -i "s/# external_url 'GENERATED_EXTERNAL_URL'/external_url \"http:\/\/$NOMDEDOMAINE_INSTANCE_GITLAB:$NO_PORT_IP_SRV_GITLAB_INSTANCE_TEST\"/g" ./etc.gitlab.rb.girofle

echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  Instance Gitlab supplémentaire de test provisionnée à l'installation Girofle - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  Contenu [./etc.gitlab.rb.girofle] APRES SUBSTITUTION : - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  DEBUT fichier config [./etc.gitlab.rb.girofle] APRES SUBSTITUTION - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
sudo cat ./etc.gitlab.rb.girofle >> $NOMFICHIERLOG
echo " provision-girofle-  FIN   fichier config [./etc.gitlab.rb.girofle] APRES SUBSTITUTION - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG

sudo docker cp ./etc.gitlab.rb.girofle $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST:./etc.gitlab.rb.girofle
sudo docker exec -it $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST /bin/bash -c "rm -f /etc/gitlab/gitlab.rb"
sudo docker exec -it $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST /bin/bash -c "cp -f ./etc.gitlab.rb.girofle /etc/gitlab/gitlab.rb"
sudo docker exec -it $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST /bin/bash -c "rm -f ./etc.gitlab.rb.girofle"
# sudo docker restart $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST
# à la place d'un redémarrage complet du conteneur, j'utilise [gitlab-ctl]
sudo docker exec -it $NOM_DU_CONTENEUR_SUPPLEMENTAIRE_POUR_TEST /bin/bash -c "gitlab-ctl reconfigure"
sudo rm -f ./etc.gitlab.rb.girofle



##########################################################################################
#								LOGS CONFIG INSTANCE GITLAB							   	 #
##########################################################################################

echo " provision-girofle-  contenu fichier config [/etc/gitlab/gitlab.rb] instance GITLAB: - " >> $NOMFICHIERLOG
echo " provision-girofle-  DEBUT fichier config [/etc/gitlab/gitlab.rb] - " >> $NOMFICHIERLOG
sudo docker exec -it $NOM_DU_CONTENEUR_CREE /bin/bash -c "more /etc/gitlab/gitlab.rb" >> $NOMFICHIERLOG
echo " provision-girofle-  FIN fichier config [/etc/gitlab/gitlab.rb] - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
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


