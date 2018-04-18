# Client Girofle

Chaque script contenu dans ce répertoire correspond à une opération standard du client girofle, en particulier poru le use case `utilisateur non-IT`

Ces scripts sont utilisés pour créer un Git repository de nom `client-girofle`, dans l'instance Gitlab intialement provisionnée.
Il y a  une attente `HEALTH_CHECK / healthy`, avant la création du Git repository `client-girofle`, et le repositroy est créé
avec un premier commit:
* qui contient seulement les fichiers contenus dans ce répertoire 
* le commit message est "Repository créé par la Provision Girofle, pour mettre en service le service de déploiement du client girofle, sous la forme d'un repository git."

# Provision du client Girofle

## Provision du client pour Cible Windows 10:

Pour ce faire, il suffit:
* d'installer Git sur Windows,
* de faire un git clone de ce repo,
* d'exécuter `installer-client-girofle.bat`

### À porpos du script `installer-client-girofle.bat`

Ce script crée un répertoire `$REPERTOIRE_CLIENT_GIROFLE`, copie les fichiers `*.sh` (`save-local.sh` et `sync-remote.sh`) dans `$REPERTOIRE_CLIENT_GIROFLE`, créée un raccourci vers le script `client-girofle.bat`

### À propos du script `client-girofle.bat`

Il s'agit du script invoqué pour exécuter toute opération du client Girofle sur Windows.
Ce script prend toujours les options suivantes en paramètre:
* [OBLIGATOIRE] le répertoire du repo git local
* [OPTIONNELLE] le nom de l'opération, l'une des deux suivantes:
  * `--backup-local`
  * `--backup-remotely`
  * par défaut, si aucune des deux options n'est précisée, c'est `--backup-local` qui s'applique
* Si l'option --bckup est utilisée, en premier argument, alors le client girofle comprend qu'il doit prendre en charge un nouveau répertoire, et le second argument:
  * S'il est précisé, c'est le chemin complet du répertoireà backupper
  * S'il n'est pas précisé, le chemin complet du nouveau répertoire à backupper avvec Girofle, est demandé interactivement.
  * Si le répertoire précisé est déjà pris en charge par Girofle (je vérifie si je trouve un `.git`, et si oui, je vérifie l'URL du repo distant origin, si c'est un repo Girofle, je sais qu'il est déjà pros en chage par Girofle et je loggue une erreur)


```
REM L'idée:  
REM Pour exécuter une opération standard client girofle, on invoque le client git "Git bash" pour
REM windows, en lui demandant d'exécuter le script *.sh qui correspond à l'opérations tandard, soit 
REM l'une des suivantes:
REM 
REM => [save-local.sh] : pour git commit
REM => [sync-remote.sh] : pour git commit && git push de tous les fichiers
REM 
REM N.B.: invocation de Git bash sous Windows 10:
REM 	set CHEMIN_EXE_GITBASH="C:\moi\mes.logiciels\git\installation\git-bash.exe"
REM 	set CHEMIN_FICHIER_SCRIPT_SH="C:\moi\IAAS\the-devops-program\garage\girofle\operations-std\client\modele\save-local.sh"
REM 	call %CHEMIN_EXE_GITBASH% --cd-to-home %CHEMIN_FICHIER_SCRIPT_SH%
REM 
```


## Provision du client pour Cible Linux

Pour ce faire, il suffit de faire un git clone, et d'exécuter 

Pour ce faire, il suffit:
* d'installer Git sur Windows,
* de faire un git clone de ce repo,
* d'exécuter `installer-client-girofle.sh`


## À venir dans les prochaines release Girofle


Le client Girofle sera déployable avec des recettes:
* en powershell, pour Windows (1 repo Git)
* en linux scripts /bin/bash (1 repo Git, un git tag pour chaque version pleinement qualifiée en regard d'uen version précise d'OS, le repo organisé en branche par OS) 
* recette ansible
* recette chef.io


# Dépendances

Les scripts présents dans ce répertoire n'ont aucune dépendance en dehors de ce répertoire, mise à part la dépendance à l'exécutable shell utilisé pour les tests. (/bin/bash)

