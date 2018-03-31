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
# 				 
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
sudo crontab ./operations-std/serveur/bckup.kytes
rm -f ./operations-std/serveur/bckup.kytes
echo " provision-girofle- Le backup Girafle a été configuré pour  " >> $NOMFICHIERLOG
echo " provision-girofle- s'exécuter automatiquent de la manière suivante: " >> $NOMFICHIERLOG
echo " provision-girofle-  " >> $NOMFICHIERLOG
echo " provision-girofle-  " >> $NOMFICHIERLOG
echo " provision-girofle-  " >> $NOMFICHIERLOG
sudo crontab -l >> $NOMFICHIERLOG
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








