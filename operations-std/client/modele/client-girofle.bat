REM TODO: à implémenter, client Girofle sur Windows 10

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
