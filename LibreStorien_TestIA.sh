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
#ceci est la ligne 29
echo -e "\n"

OLLAMA_IP="10.3.50.48"
MODEL_LIST_FILENAME=".tmp/installed_models.json"
: > MODEL_LIST_FILENAME

GET_MODEL_LIST="curl -s http://${OLLAMA_IP}:11434/api/tags | jq  > $MODEL_LIST_FILENAME"
TEST_MODEL_LIST="jq --arg MODEL ${MODEL} '.models[] | select(.name == $MODEL)' $MODEL_LIST_FILENAME"
LIKE_MODEL_LIST="jq --arg MODEL ${MODEL} '.models[] | select(.name | contains ($MODEL)) | .name' $MODEL_LIST_FILENAME"
PULL_MODEL="curl -s http://${OLLAMA_IP}:11434/api/pull -d '{\"model\": \"${MODEL}\"}'"

while true; do # Demande et vérifie que le modèle est bien installé
    read -p "Quel est le modèle à tester ? : " MODEL

    #Obtient la liste  des modèle et la compare avec le modèle choisi
    GET_MODEL_LIST=$(curl -s http://${OLLAMA_IP}:11434/api/tags | jq  > $MODEL_LIST_FILENAME)
    MODEL_FOUND=$(jq --arg MODEL "$MODEL" -r '.models[] | select(.name == $MODEL) | .name' "$MODEL_LIST_FILENAME")
    # Vérifie si le modèle existe déjà dans la liste d'Ollama

    if  [ -n "$MODEL_FOUND" ]; then
        echo "Modèle '$MODEL' trouvé localement."
        break
    else
        SIMILAR_MODEL_FOUND=$(eval "$LIKE_MODEL_LIST")
        if [ -n "$SIMILAR_MODEL_FOUND" ]; then
                read -p "Des modèles similaires ont été trouvés. Voulez-vous dire : $SIMILAR_MODEL_FOUND ? (Y/N)" rep
        	case "$rep" in
            	    [Yy])
			exit 0
                        ;;
                    [Nn])
			break
                        ;;
            	    *)
		        echo "Réponse invalide. Répondez par Y ou N."
                	;;
        	esac
        else
            echo " Le modèle '$MODEL' n'est pas installé."
            read -p "Voulez-vous le télécharger maintenant ? (Y/N) : " rep
            case "$rep" in
                [Yy])
                    echo "Téléchargement de '$MODEL'..."
                    PULL__MODEL=$(curl -s http://${OLLAMA_IP}:11434/api/pull -d '{\"model\": \"${MODEL}\"}')
                    # On revérifie qu'il a bien été installé
                    GET_MODEL_LIST=$(curl -s http://${OLLAMA_IP}:11434/api/tags | jq  > $MODEL_LIST_FILENAME)
                    MODEL_FOUND=$(jq --arg MODEL "$MODEL" -r '.models[] | select(.name == $MODEL) | .name' "$MODEL_LIST_FILENAME")

                    if  [ -n "$MODEL_FOUND" ]; then
                        echo "Modèle téléchargé avec succès."
                        break
                    else
                        echo "Échec du téléchargement. Veuillez réessayer."
                    fi
                    ;;
                [Nn])
                    echo "Veuillez entrer un autre modèle."
                    exit 0
		    ;;
                *)
                    echo "Réponse invalide. Répondez par Y ou N."
                    ;;
            esac
        fi
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
    elif [[ "$Save_temp" != *.json ]]; then
        echo "Le fichier de sauvegarde doit avoir l'extension .json"
    elif [[ "$Save_temp" =~ $caracteres_invalides ]]; then
        echo "Le nom de fichier contient des caractères non valides."
    else
	Save="./DATA_Rep/$Save_temp"
        echo "Fichier de sauvegarde : $Save_temp"
        break
    fi
done

echo -e "\n"

while true; do #Demande à l'utilisateur s'il veut réinitialiser le fichier de sauvegarde
    read -p "Voulez-vous effacer le contenu du fichier $Save ? [Y/N] : " reponse
    case "$reponse" in
        [Yy])
            : > "$Save"
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
echo "Modèle : $Model" >> $Save
echo "Prompt : $Fichier" >> $Save
echo "Ficher cible : $Save_temp" >> $Save

echo "Modèle : $Model"
echo "Prompt : $Fichier"
echo "Ficher cible : $Save_temp"

echo -e "\n"
echo -e "-----------------------------------------------------------------------------------------------------------------------------------------\n"\
		 >> $Save

while IFS= read -r ligne; do #Boucle while qui parcours ligne par ligne le document dans lequel se trouve les prompts de test
    echo "==== Réponse pour : $ligne ====" >> $Save #Enregistre la question posé
    echo "==== Réponse pour : $ligne ===="
    #Génere la réponse du modèle et l'enregistre dans un document

    #curl -s "http://${OLLAMA_IP}:11434/api/generate" -H "Content-Type: application/json" -d "{\"model\": \"$MODEL\", \"prompt\": \"$ligne\"}" | jq -r '.response' | tr -d '\n' >> $Save
    json=$(jq -n --arg model "$MODEL" --arg prompt "$ligne" '{model: $model, prompt: $prompt}')
    curl -s "http://${OLLAMA_IP}:11434/api/generate" -H "Content-Type: application/json" -d "$json" \
     							 | jq -r '.response' | tr -d '\n' >> $Save

    echo -e "-----------------------------------------------------------------------------------------------------------------------------------------\n"\
		 >> $Save

    echo -e "\nLa génération a été faite avec sucèss"
    echo -e "\n"

done < "$Question" #Spécifie que l'on utilise le document question

echo "###############################################################################################"
echo -e "\nLe Test a été effectué avec sucèss"
echo -e "\n"
