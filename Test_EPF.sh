#!/bin/bash


## Using OLLAMA API : https://github.com/ollama/ollama/blob/main/docs/api.md


MODEL="mistral-small:latest"


if [ -e "$MODEL" ]; then

	echo "Attention, la variable MODEL n'est pas définie"

	exit -1

fi



OLLAMA_IP=

TMP_DIR=".tmp"

mkdir -p $TMP_DIR

MODEL_LIST_FILENAME="$TMP_DIR/installed_models.json"

GET_MODEL_LIST="curl -s http://${OLLAMA_IP}:11434/api/tags | jq  > $MODEL_LIST_FILENAME"

TEST_MODEL_LIST="jq --arg MODEL ${MODEL} '.models[] | select(.name == \$MODEL)' $MODEL_LIST_FILENAME"

LIKE_MODEL_LIST="jq --arg MODEL ${MODEL} '.models[] | select(.name | contains (\$MODEL)) | .name' $MODEL_LIST_FILENAME"

PULL_MODEL="curl -s http://${OLLAMA_IP}:11434/api/pull -d '{\"model\": \"${MODEL}\"}'"


eval "$GET_MODEL_LIST"

MODEL_FOUND=$(eval "$TEST_MODEL_LIST")


if [ -n "$MODEL_FOUND" ]; then

	echo "Modèle '$MODEL' trouvé localement."

else

	echo " Le modèle '$MODEL' n'est pas installé."

	SIMILAR_MODEL_FOUND=$(eval "$LIKE_MODEL_LIST")

	if [ -n "$SIMILAR_MODEL_FOUND" ]; then

		echo "Trouvés des modèles similaires. Vouliez-vous dire : $SIMILAR_MODEL_FOUND ?"

	fi

	read -p "Voulez-vous télécharger "$MODEL" maintenant ? (y/N) : " rep

	if [ "${rep,,}" == "y" ]; then # Note ${TEXT,,} syntax put all the text in lowercase

		eval "$PULL_MODEL"

	else # if not yes, default to quiting

		exit 0

	fi

fi


# Dossier contenant les fichiers .txt

DOSSIER="./Prompt"


# Parcourir tous les fichiers .txt du dossier

for fichier in "$DOSSIER"/*.txt; do

    echo "Traitement du fichier : $fichier"

    

    # Lire chaque ligne (chaque question) du fichier

    while IFS= read -r question; do

        echo "Envoi de la question : $question"

        

        # Construire le prompt curl avec la question

        curl -s http://${OLLAMA_IP}:11434/api/generate \

            -H "Content-Type: application/json" \

            -d "{\"model\": \"gemma2:2b\", \"prompt\": \"$question\", \"stream\": false}"


        echo # pour sauter une ligne entre les réponses

    done < "$fichier"

done

