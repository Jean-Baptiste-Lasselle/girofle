# Opérations Standard d'exploiation Girofle

Chaque script contenu dans ce répertoire correspond à une opération standard d'e'xploiation (d'adminsitration, si vous voulez)
de Girofle.

Les opérations standars disponibles sont:

* [backup.sh]: Ce script permet de "backupper" une instance Gitlab gérée par Girofle.
* [restore.sh]: Ce script permet de restaurer une instance Gitlab gérée par Girofle, qui a été "backuppée".
* [lister-instances-gitlab.sh]: Ce script permet à l'adminsitrateur, à tout moment, de lister les instances gitlab en cours d'exploitation par Girofle.
* [decomissioner-instance-gitlab.sh]: Ce script permet à l'adminsitrateur, à tout moment, de dé-commisionner (détruire proprement), une instance gitlab en cours d'exploitation par Girofle.

## À venir dans la prochaine release Girofle:

* [comissioner-instance-gitlab.sh]: Ce script permet à l'adminsitrateur, à tout moment, de commisionner (détruire proprement), une Nouvelle instance gitlab avec Girofle. [Cette fonctionnalité est à vernir dans la prochaine release]


# Dépendances

Les scripts présents dans ce répertorie n'ont aucune dépendance en dehors de ce répertoire, mise à part la dépendance à l'exécutable shell utilisé pour les tests. (/bin/bash)


# Provision Girofle


À la provision, le contenu de ce répertoire est copié dans le répertoire `$REPEROIRE_GIROFLE/operations-std`.



