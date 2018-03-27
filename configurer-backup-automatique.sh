# installation de Docker sur centos 7
																						
# update CentOS 7
sudo yum clean all -y && sudo yum update -y
# DOCKER EASE BARE-METAL-INSTALL - CentOS 7
sudo systemctl stop docker
sudo systemctl start docker


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
##############################################################################################################################################
#########################################							FONCTIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							OPS								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------------------------------------
# 			CONFIGURATION DU SYSTEME POUR BACKUP AUTYOMATISES		==>> CRONTAB 
# --------------------------------------------------------------------------------------------------------------------------------------------

# 1./ il faut ajouter la ligne:
# => pour une toutes les 4 heures: [* */4 * * * "$(pwd)/operations-std/serveur/backup.sh"]
#     Ainsi, il suffit de laisser le serveur en service pendant 4 heures pour être sûr qu'il y ait eu un backup.
# => pour une fois par nuit: [*/5 */1 * * * "$(pwd)/operations-std/serveur/backup.sh"]
# => Toutes les 15 minutes après 7 heures: [5 7 * * * "$(pwd)/operations-std/serveur/backup.sh" ]
# 
# Au fichier crontab:
# 
# Mode manuel: sudo crontab -e

# TODO: devra devenir un argument de l'invocatione n ligne de commande
export CHEMIN_INVOCATION_BACK_UP="$(pwd)/operations-std/serveur/backup.sh"

# Une fois toutes les 3 minutes, pour les tests crontab
# export PLANIFICATION_DES_BCKUPS="* */4 * * *   $(pwd)/operations-std/serveur/backup.sh"
export PLANIFICATION_DES_BCKUPS="3 * * * * $CHEMIN_INVOCATION_BACK_UP"


rm -f ./operations-std/serveur/bckup.kytes
echo "$PLANIFICATION_DES_BCKUPS" >> ./operations-std/serveur/bckup.kytes
crontab ./operations-std/serveur/bckup.kytes
rm -f ./operations-std/serveur/bckup.kytes
echo " provision-girofle- Le backup Girafle a été configuré pour  " >> $NOMFICHIERLOG
echo " provision-girofle- s'exécuter automatiquent de la manière suivante: " >> $NOMFICHIERLOG
echo " provision-girofle-  " >> $NOMFICHIERLOG
echo " provision-girofle-  " >> $NOMFICHIERLOG
echo " provision-girofle-  " >> $NOMFICHIERLOG
crontab -l >> $NOMFICHIERLOG
echo " provision-girofle-  " >> $NOMFICHIERLOG
echo " provision-girofle-  " >> $NOMFICHIERLOG
echo " provision-girofle-  " >> $NOMFICHIERLOG


#    ANNEXE crontab quickies
# => pour une fois par nuit: ["* 1 * * * $CHEMIN_INVOCATION_BACK_UP"]
# => pour une toutes les 2 heures: ["* */2 * * * $CHEMIN_INVOCATION_BACK_UP"]
# => pour une toutes les 4 heures: ["* */4 * * * $CHEMIN_INVOCATION_BACK_UP"]
# => pour une fois par nuit: ["*/5 */1 * * * $CHEMIN_INVOCATION_BACK_UP"]
# => Toutes les 15 minutes après 7 heures: ["5 7 * * * $CHEMIN_INVOCATION_BACK_UP" ]
# => Toutes les 3 minutes: ["3 * * * * $CHEMIN_INVOCATION_BACK_UP" ]








