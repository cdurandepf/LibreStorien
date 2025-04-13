# Installation de WSL2 et de l'Outil LibreStorien

## 1. Installer WSL2 sur Windows

1. **Ouvrez PowerShell** (*Attention : utilisez PowerShell et non CMD*) en tant qu'administrateur.
2. Exécutez la commande suivante pour installer WSL et Ubuntu automatiquement :
```
wsl --install 
```
3. Redémarrez votre ordinateur si cela est demandé.
4. Pour installer Ubuntu, tapez la commande suivante dans PowerShell :
```
wsl --install -d Ubuntu
```
5. Lancez Ubuntu avec la commande suivante :
```
wsl.exe -d Ubuntu
```
6. Suivez les instructions à l’écran pour créer un utilisateur et un mot de passe.
7. (Optionnel) Vérifiez la version installée avec :
```
wsl --list --verbose
```
8. Pour définir WSL2 comme version par défaut, exécutez dans PowerShell :
```
wsl --set-default-version 2
```


## 2. Installer l'Outil LibreStorien dans WSL2 (Ubuntu)

9. Ouvrez Ubuntu via la commande :
```
wsl.exe -d Ubuntu
```
10. Assurez-vous que Git est installé :
 ```
 sudo apt update && sudo apt install -y git
 ```
11. Clonez le dépôt GitHub du projet LibreStorien :
 ```
 git clone https://github.com/cdurandepf/LibreStorien.git
 ```
12. Accédez au dossier du projet :
 ```
 cd LibreStorien
 ```
13. Rendez les scripts exécutables :
 ```
 chmod +x LibreStorien_Initialisation.sh LibreStorien_TestIA.sh
 ```
14. Lancez le script d'initialisation :
 ```
 bash LibreStorien_Initialisation.sh
 ```
15. Lancez ensuite le test IA :
 ```
 bash LibreStorien_TestIA.sh
 ```

---

💡 **Conseil :** 
Assurez-vous d'avoir une connexion internet active pour que l'installation des dépendances se passe bien.

