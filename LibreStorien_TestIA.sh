#!/bin/bash
# =============================================================================
# Script : LibreStorien_TestIA.sh
# Auteur : DURAND Corentin
# Date   : 09/04/2025
#
# Description :
# Ce script permet de tester un modèle local Ollama (ex : llama3, mistral, etc.)
# sur une série de prompts stockés dans un fichier texte.
# Pour chaque ligne du fichier, le script envoie le texte comme prompt au modèle,
# récupère la réponse et l'ajoute dans un fichier de sortie "Rep_a_analys.txt".
#
# Usage :
#   - L'utilisateur est invité à saisir :
#       1. Le nom du modèle Ollama à utiliser (ex : llama3, mistral, etc.)
#       2. Le nom d'un fichier texte contenant les prompts (un par ligne)
#   - Ce fichier doit se trouver dans : ./Prompt
#
# Prérequis :
#   - Ollama doit être installé et fonctionnel sur la machine.
#     (https://ollama.com/)
#   - Le modèle spécifié doit déjà avoir été téléchargé via `ollama pull <model>`
#   - Le fichier de prompts doit être en format texte (.txt), encodé en UTF-8.
#
# Fichier de sortie :
#   - Toutes les réponses sont ajoutées dans le répertoire ./DATA_Rep
#     au nom que l'utilisateur rentre.
# =============================================================================

echo -e "\n"

while true; do # Demande et vérifie que le modèle est bien installé
    read -p "Quel est le modèle à tester ? : " Model
    # Vérifie si le modèle existe déjà dans la liste d'Ollama
    if ollama list | grep -q "$Model"; then
        echo "Modèle '$Model' trouvé localement."
        break
    else
        echo " Le modèle '$Model' n'est pas installé."
        read -p "Voulez-vous le télécharger maintenant ? (Y/N) : " rep
        case "$rep" in
            [Yy])
                echo "Téléchargement de '$Model'..."
                ollama pull "$Model"
                # On revérifie qu'il a bien été installé
                if ollama list | grep -q "^$Model[[:space:]]"; then
                    echo "Modèle téléchargé avec succès."
                    break
                else
                    echo "Échec du téléchargement. Veuillez réessayer."
                fi
                ;;
            [Nn])
                echo "Veuillez entrer un autre modèle."
                ;;
            *)
                echo "Réponse invalide. Répondez par Y ou N."
                ;;
        esac
    fi
done

echo -e "\n"

while true; do # Vérifie que le fichier de prompt existe et est bien un .txt
    read -p "Quel est le fichier de prompt ? : " Fichier
    Question="./Prompt/$Fichier"

    if [[ ! -f "$Question" ]]; then
        echo "Fichier introuvable à l'emplacement : $Question"
    elif [[ "$Fichier" != *.txt ]]; then
        echo "Le fichier doit être au format .txt"
    else
        echo "Fichier de prompt valide : $Fichier"
        break
    fi
done
echo -e "\n"

while true; do # Demande un nom de fichier de sauvegarde valide
    caracteres_invalides='[/:*\?\"<>|]'
    read -p "Nom du fichier de sauvegarde des réponses : " Save_temp
    if [[ -z "$Save_temp" ]]; then
        echo "Le nom de fichier ne peut pas être vide."
    elif [[ "$Save_temp" != *.txt ]]; then
        echo "Le fichier de sauvegarde doit avoir l'extension .txt"
    elif [[ "$Save_temp" =~ $caracteres_invalides ]]; then
        echo "Le nom de fichier contient des caractères non valides."
    else
        Save="./DATA_Rep/$Save_temp"
        echo "Fichier de sauvegarde : $Save_temp"
        break
    fi
done

echo -e "\n"

while true; do #Demande à l'utilisateur si il veut réisignaliser le fichier de sauvegarde
    read -p "Voulez-vous effacer le fichier $Save ? [Y/N] : " reponse
    case "$reponse" in
        [Yy])
            rm -f "$Save"
            echo "Fichier supprimé."
            break
            ;;
        [Nn])
            echo "Fichier conservé."
            break
            ;;
        *)
            echo "Réponse invalide. Veuillez répondre par Y ou N."
            ;;
    esac
done

echo -e "\n"
echo "###############################################################################################"
echo -e "\n"
echo "Initialisation du Test"
echo -e "\n"

echo -e "\n" >> $Save
echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"\
                 >> $Save
echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"\
                 >> $Save
echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"\
                 >> $Save
echo -e "\n" >> $Save
echo -e "-----------------------------------------------------------------------------------------------------------------------------------------\n"\
                 >> $Save

while IFS= read -r ligne; do #Boucle while qui parcours ligne par ligne le document dans le quel ce trouve les prompte de teste
    echo "==== Réponse pour : $ligne ===="
    echo "$ligne" | ollama run "$Model" >> $Save #Génere la reponse du modèle et l'enregistre dans un doc nommé Rep_a_analys.txt
    echo -e "-----------------------------------------------------------------------------------------------------------------------------------------\n"\
                 >> $Save
    echo "La génération à été faite avec sucess"
    echo -e "\n"
done < "$Question" #Sécifie que l'on utilise le document question

echo "###############################################################################################"
echo -e "\nLe Test à été effectuer avec sucess"
echo -e "\n"