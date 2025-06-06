#!/bin/bash


## Using OLLAMA API : https://github.com/ollama/ollama/blob/main/docs/api.md


MODEL="mistral-small:latest"


if [ -e "$MODEL" ]; then

	echo "Attention, la variable MODEL n'est pas définie"

	exit -1

fi



OLLAMA_IP="10.3.50.48"

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
OUTPUT_DIR="./resultats"  # Dossier pour les résultats
mkdir -p "$OUTPUT_DIR"
extract_qa() {

     output_text="=== QUESTION ===
     input_content="$1"

$question
     output_file="$2"


=== RÉPONSE ===
    

$response
    # Extraire la question


"
    question=$(echo "$input_content" | grep "^Envoi de la question :" | sed 's/^Envoi de la question : //')

    

    # Écrire dans le fichier
    

    echo "$output_text" >> "$output_file"
    # Extraire la réponse

}


echo "Traitement des fichiers dans le dossier : $DOSSIER"
    response_line=$(echo "$input_content" | grep '"response":"' | head -1)

echo "Serveur Ollama : $OLLAMA_IP:11434"
   

echo "Résultats dans : $OUTPUT_DIR"
    

echo "----------------------------------------"
    # Créer le contenu formaté


# Boucle pour chaque fichier .txt
    local output_text="=== QUESTION ===
for fichier in "$DOSSIER"/*.txt; do

    # Vérifier si le fichier existe (au cas où il n'y a pas de fichiers .txt)

    if [[ ! -f "$fichier" ]]; then

        echo "Aucun fichier .txt trouvé dans $DOSSIER"

        continue

    fi

    

    echo "Traitement du fichier : $fichier"

    

    # Créer un nom de fichier de sortie basé sur le fichier d'entrée

    nom_base=$(basename "$fichier" .txt)

    fichier_sortie="$OUTPUT_DIR/${nom_base}_qa.txt"

    

    # Vider le fichier de sortie s'il existe

    > "$fichier_sortie"

    

    # Compteur pour suivre les questions

    compteur=1

    

    # Lire chaque ligne (chaque question) du fichier

    while IFS= read -r question; do

        # Ignorer les lignes vides

        if [[ -z "$question" ]]; then

            continue

        fi

        

        echo "  Question $compteur : $question"

        

        # Capturer toute la sortie curl + echo

        output_complet=$(

            echo "Envoi de la question : $question"

            curl -s "http://${OLLAMA_IP}:11434/api/generate" \

                -H "Content-Type: application/json" \

                -d "{\"model\": \"gemma2:2b\", \"prompt\": \"$question\"}"

        )

        

        # Extraire et sauvegarder la Q&R

        extract_qa "$output_complet" "$fichier_sortie"

        

        echo "    → Réponse sauvegardée"

        

        # Incrémenter le compteur

        ((compteur++))

        

        # Pause courte pour éviter de surcharger le serveur

        sleep 0.5

        

    done < "$fichier"

    

    echo "  ✓ Fichier $fichier traité → $fichier_sortie"

    echo

done


echo "----------------------------------------"

echo "Traitement terminé. Résultats disponibles dans : $OUTPUT_DIR"
