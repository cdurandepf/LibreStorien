#!/bin/bash
# =============================================================================
# Script : LibreStorien_Installation.sh
# Auteur : DURAND Corentin
# Date   : 10/04/2025
#
# Description :
# Ce script initialise l'environnement nécessaire pour exécuter LibreStorien :
#   - Crée le dossier "Prompt" s'il n'existe pas, ainsi qu'un fichier de test
#     "1er_prompt.txt" contenant 4 questions types.
#   - Crée le dossier "DATA_Rep" s'il n'existe pas, pour stocker les résultats.
#   - Vérifie si le logiciel Ollama est installé :
#       * Si oui, vérifie s'il est à jour en comparant avec la version GitHub.
#         Propose à l'utilisateur de le mettre à jour si nécessaire.
#       * Si non, propose de l’installer automatiquement selon le système.
#
# Prérequis :
#   - Une connexion Internet fonctionnelle (pour curl et mise à jour).
#   - Pour Linux : fonctionne sur des distributions utilisant `apt`.
#   - Pour macOS : nécessite Homebrew.
#
# Remarques :
#   - Ollama est requis pour utiliser les fonctionnalités principales de LibreStorien.
#   - Ce script est à exécuter une seule fois lors de la mise en place du projet.
# =============================================================================
 

# Vérifier si le répertoire "Prompt" existe

echo -e "\n"
echo "Demarage de l'instalation"
echo -e "\n"

# Vérifie si jq est installé
if ! command -v jq &> /dev/null; then
    echo "Le module 'jq' n'est pas installé."
    read -p "Voulez-vous l'installer maintenant ? (Y/N) : " response
    case "$response" in
        [Yy])
            echo "Installation de jq..."
            if [[ "$(uname)" == "Linux" ]]; then
                sudo apt update
                sudo apt install -y jq
            elif [[ "$(uname)" == "Darwin" ]]; then
                brew install jq
            else
                echo "Système non supporté pour l'installation automatique."
                exit 1
            fi
            ;;
        [Nn])
            echo "Installation annulée. Le module 'jq' est requis pour continuer."
            ;;
        *)
            echo "Réponse invalide. Veuillez relancer le script et répondre par Y ou N."
            ;;
    esac
else
    echo "'jq' est déjà installé."
fi

if [[ ! -d "Prompt" ]]; then
    echo "Le répertoire 'Prompt' n'existe pas. Création..."
    mkdir "Prompt"

    # Créer un fichier '1er_prompt.txt' avec 4 questions
    echo -e "Quelle est votre couleur préférée ?\nQuel est votre animal préféré ?\nD'où venez-vous ?\nQuel est votre plat préféré ?" \
                                                                                                             > "Prompt/1er_prompt.txt"
    echo "Fichier '1er_prompt.txt' créé dans 'Prompt'."
else
    echo "Le répertoire 'Prompt' existe déjà."
fi

# Vérifier si le répertoire "DATA_Rep" existe
if [[ ! -d "DATA_Rep" ]]; then
    echo "Le répertoire 'DATA_Rep' n'existe pas. Création..."
    mkdir "DATA_Rep"
else
    echo "Le répertoire 'DATA_Rep' existe déjà."
fi

echo -e "\n"

#!/bin/bash

# Fonction pour vérifier si Ollama est installé
check_ollama_installed() {
    if command -v ollama &> /dev/null; then
        echo "Ollama est installé."
        return 0  # Ollama est installé
    else
        echo "Ollama n'est pas installé."
        return 1  # Ollama n'est pas installé
    fi
}

# Fonction pour vérifier si Ollama est à jour
check_ollama_update() {
    echo "Vérification de la version d'Ollama..."
    # Utilisation de "ollama --version" pour obtenir la version actuelle
    local current_version
    current_version=$(ollama --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

    local latest_version=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest | jq -r .tag_name | sed 's/^v//')
    #Curl the last version of ollama

    if [[ "$current_version" != "$latest_version" ]]; then
        echo "Ollama n'est pas à jour. Version actuelle : $current_version, dernière version : $latest_version."
        return 1  # Pas à jour
    else
        echo "Ollama est à jour (version $current_version)."
        return 0  # À jour
    fi
}

# Fonction pour installer Ollama
install_ollama() {
    echo "Installation d'Ollama..."
    # Utilisez les commandes appropriées selon le système d'exploitation
    if [[ "$(uname)" == "Linux" ]]; then
        # Pour Ubuntu/Debian
        sudo apt update
        sudo apt install -y ollama
    elif [[ "$(uname)" == "Darwin" ]]; then
        # Pour macOS avec Homebrew
        brew install ollama
    else
        echo "Système non supporté pour l'installation automatique."
        return 1
    fi
}

# Vérification si Ollama est installé
if check_ollama_installed; then
    # Si Ollama est installé, vérifiez si il est à jour
    if ! check_ollama_update; then
        read -p "Voulez-vous mettre à jour Ollama ? (Y/N) : " response
        if [[ "$response" =~ [Yy] ]]; then
            echo "Mise à jour d'Ollama..."
            if [[ "$(uname)" == "Linux" ]]; then
                sudo apt update && sudo apt upgrade -y ollama
            elif [[ "$(uname)" == "Darwin" ]]; then
                brew upgrade ollama
            fi
        else
            echo "Ollama ne sera pas mis à jour."
        fi
    fi
else
    # Ollama n'est pas installé, on le propose d'installer
    read -p "Ollama n'est pas installé. Voulez-vous l'installer ? (Y/N) : " response
    if [[ "$response" =~ [Yy] ]]; then
        install_ollama
        echo "Ollama a été installé"
    else
        echo "Ce module est nécessaire pour le fonctionnement de LibreStorien"
    fi
fi

echo -e "\n"
echo "L'installation a été réussi avec succes"
echo -e "\n"
