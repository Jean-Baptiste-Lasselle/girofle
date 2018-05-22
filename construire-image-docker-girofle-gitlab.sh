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
# Ce dockerfile est tesrté, fonctionnel.
echo "FROM $VERSION_IMAGE_OFFICIELLE_DOCKER_GITLAB" >> $DOCKERFILE_INSTANCES_GITLAB
echo "LABEL name=\"gitlab.girofle.io\" \\" >> $DOCKERFILE_INSTANCES_GITLAB
echo "   vendor=\"SOPRASTERIA\" \\" >> $DOCKERFILE_INSTANCES_GITLAB
echo "   license=\"GPLv2\" \\" >> $DOCKERFILE_INSTANCES_GITLAB
DATEDEMONBUILD=`date +"%M/%d/%Y %Hh%Mmin%Ssec"`
echo "   build-date=\"$DATEDEMONBUILD\" " >> $DOCKERFILE_INSTANCES_GITLAB
# echo "RUN apt-get remove -y libappstream3 && apt-get update -y" >> $DOCKERFILE_INSTANCES_GITLAB
echo "# Configuration Proxy de l' infrastructure dans laquelle j'opère " >> $DOCKERFILE_INSTANCES_GITLAB


######################################################################################################
######################################################################################################
##########							OPERATIONS CHIRURGICALES								########## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
######################################################################################################
######################################################################################################

echo "# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- " >> $DOCKERFILE_INSTANCES_GITLAB
echo "#  " >> $DOCKERFILE_INSTANCES_GITLAB
echo "#  " >> $DOCKERFILE_INSTANCES_GITLAB
echo "export PROXY_HOST=w.x.y.z " >> $DOCKERFILE_INSTANCES_GITLAB
echo "export PROXY_NO_PORT_IP=8380 " >> $DOCKERFILE_INSTANCES_GITLAB
echo "export OPERATEUR_SOLUTION=$USER " >> $DOCKERFILE_INSTANCES_GITLAB
echo "export OPERATEUR_SOLUTION_MDP=jailairdeversionnermesmotsdepassesfranchement " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- " >> $DOCKERFILE_INSTANCES_GITLAB
echo "#  " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# Dans le fichier [/etc/apt/apt.conf.d/80proxy], ajouter le contenu exact : " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# Acquire::http::proxy \"http://<username>:<password>@<proxy>:<port>/\"; " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# Acquire::ftp::proxy \"ftp://<username>:<password>@<proxy>:<port>/\"; " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# Acquire::https::proxy \"https://<username>:<password>@<proxy>:<port>/\"; " >> $DOCKERFILE_INSTANCES_GITLAB

echo "export FICHIER_TEMPORAIRE=./apt.conf.d.80proxy " >> $DOCKERFILE_INSTANCES_GITLAB
echo "export FICHIER_CONF_PAKG_MNGR=/etc/apt/apt.conf.d/80proxy " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# I'll just assume $FICHIER_CONF_PAKG_MNGR doesn't exist yet. " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# Yes I can. Because I build my own system from scratch, in a docker image " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# ============================================================================================================================================= " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# 1./ On génère $FICHIER_CONF_PAKG_MNGR " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# ============================================================================================================================================= " >> $DOCKERFILE_INSTANCES_GITLAB
echo "touch $FICHIER_TEMPORAIRE " >> $DOCKERFILE_INSTANCES_GITLAB
echo "echo 'Acquire::http::proxy \"http://$OPERATEUR_SOLUTION:$OPERATEUR_SOLUTION_MDP@$PROXY_HOST:$PROXY_NO_PORT_IP/\";' >> $FICHIER_TEMPORAIRE " >> $DOCKERFILE_INSTANCES_GITLAB
echo "echo 'Acquire::ftp::proxy \"ftp://$OPERATEUR_SOLUTION:$OPERATEUR_SOLUTION_MDP@$PROXY_HOST:$PROXY_NO_PORT_IP/\";' >> $FICHIER_TEMPORAIRE " >> $DOCKERFILE_INSTANCES_GITLAB
echo "echo 'Acquire::https::proxy \"https://$OPERATEUR_SOLUTION:$OPERATEUR_SOLUTION_MDP@$PROXY_HOST:$PROXY_NO_PORT_IP/\";' >> $FICHIER_TEMPORAIRE " >> $DOCKERFILE_INSTANCES_GITLAB

echo "# Hand oui installe heat on ze système, quoi " >> $DOCKERFILE_INSTANCES_GITLAB
echo "sudo cp -f $FICHIER_TEMPORAIRE $FICHIER_CONF_PAKG_MNGR " >> $DOCKERFILE_INSTANCES_GITLAB

echo "# ============================================================================================================================================= " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# 2./ On redonne les mêmes attributs SGF / PAM que dans tous les systèmes CentOS 7 " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# ============================================================================================================================================= " >> $DOCKERFILE_INSTANCES_GITLAB
echo "#  " >> $DOCKERFILE_INSTANCES_GITLAB
echo "sudo chown -R root:root $FICHIER_CONF_PAKG_MNGR " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# on enlève tous les droits à tout le monde " >> $DOCKERFILE_INSTANCES_GITLAB
echo "sudo chmod a-r-w-x   $FICHIER_CONF_PAKG_MNGR " >> $DOCKERFILE_INSTANCES_GITLAB
echo "# pour ne mette que les exacts droits tels qu'ils sont au commissionning d'un CentOS 7 " >> $DOCKERFILE_INSTANCES_GITLAB
echo "sudo chmod u+r+w   $FICHIER_CONF_PAKG_MNGR " >> $DOCKERFILE_INSTANCES_GITLAB
echo "sudo chmod g+r   $FICHIER_CONF_PAKG_MNGR " >> $DOCKERFILE_INSTANCES_GITLAB


######################################################################################################
######################################################################################################
##########							FIN OPERATIONS CHIRURGICALES							########## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
######################################################################################################
######################################################################################################


echo "RUN apt-get update -y" >> $DOCKERFILE_INSTANCES_GITLAB

# HEALTH_CHECK
# echo "CMD [\"/usr/local/bin/wrapper\"]" >> $DOCKERFILE_INSTANCES_GITLAB
# Les 2 HEALTH_CHECK distincts permettent de discriminer les échecs causés par
# la configuration réseau / DNS  de la cible de déploiement. Ils devront être refactorisé en un unique agent
# On ne fait donc pas de vérification de la configuration dNS? on passe uniquement par adresse IP pour le HEALTH_CHECK unique
# ===>>>> IL FAUT PERMETTRE DE RENDRE CONFIGURABLE A L'EXECUTION CES PARAMETRES DU GENRE [docker run .... -e NOMDEDOMAINE_INSTANCE_GITLAB=sopra.cardiff.scm -e NO_PORT_IP_SRV_GITLAB=8880]
echo "HEALTHCHECK --interval=1s --timeout=300s --start-period=1s --retries=300 CMD curl --fail http://$ADRESSE_IP_SRV_GITLAB:$NO_PORT_IP_SRV_GITLAB/ || exit 1" >> $DOCKERFILE_INSTANCES_GITLAB
# echo "HEALTHCHECK --interval=5m --timeout=3s --start-period=1 --retries=17 CMD curl --fail http://$NOMDEDOMAINE_INSTANCE_GITLAB:$NO_PORT_IP_SRV_GITLAB/ || exit 1" >> $DOCKERFILE_INSTANCES_GITLAB
# echo "CMD [\"/usr/local/bin/wrapper\"]" >> $DOCKERFILE_INSTANCES_GITLAB
# echo "CMD [\"/bin/bash\"]" >> $DOCKERFILE_INSTANCES_GITLAB



echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  ---------------------	 DOCKERFILE IMAGE GITLAB      ----------------------- " >> $NOMFICHIERLOG
echo " provision-girofle-  ------------------------------------------------------------------------------ " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
echo " provision-girofle-  - " >> $NOMFICHIERLOG
sudo cat $DOCKERFILE_INSTANCES_GITLAB >> $NOMFICHIERLOG
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


