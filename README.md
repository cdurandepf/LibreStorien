# LibreStorien - Scripts d'Installation et de Test de Modèles IA (Ollama)

## 📦 Présentation

**LibreStorien** est un ensemble de scripts bash conçus pour :
- Préparer un environnement de test pour des modèles d’IA locaux via **Ollama**
- Lancer automatiquement des tests à partir de fichiers contenant des prompts

L’objectif est de faciliter les tests de modèles IA (comme `llama3`, `mistral`, etc.) avec une série de questions, et de stocker les réponses dans un fichier de sortie propre.

---

## 📁 Contenu des scripts

### 1. `LibreStorien_Installation.sh`

Ce script prépare l’environnement nécessaire :

- Crée le dossier `Prompt/` avec un fichier de test `1er_prompt.txt` contenant 4 questions types
- Crée le dossier `DATA_Rep/` pour stocker les réponses générées
- Vérifie si le logiciel **Ollama** est installé :
  - Si oui, vérifie qu'il est à jour (comparaison avec la dernière version sur GitHub)
  - Si non, propose de l’installer automatiquement (Linux ou macOS)
- Vérifie également si le module `jq` est présent (utilisé pour lire l'API GitHub)

---

### 2. `LibreStorien_TestIA.sh`

Ce script permet de tester un modèle IA local :

1. Demande à l'utilisateur :
   - Le nom du modèle Ollama à tester (`llama3`, `mistral`, etc.)
   - Un fichier `.txt` contenant des prompts (dans le dossier `Prompt/`)
   - Un prompt par ligne dans le document donné
   - Le nom du fichier `.txt` de sauvegarde (dans `DATA_Rep/`)

2. Vérifie que :
   - Le modèle est bien installé (sinon propose de le télécharger)
   - Le fichier de prompt est valide (existant et `.txt`)
   - Le nom du fichier de sauvegarde ne contient pas de caractères interdits

3. Pour chaque ligne du fichier de prompt :
   - Envoie le texte au modèle Ollama
   - Enregistre la réponse dans le fichier de sortie, avec des séparateurs lisibles

---

## ✅ Prérequis

Avant de lancer les scripts, assure-toi d’avoir :

- **Ollama** installé : [https://ollama.com/](https://ollama.com/)
- Un modèle déjà téléchargé via `ollama pull <nom_du_modèle>`
- Le module `jq` installé (`sudo apt install jq` ou `brew install jq`)
- Une connexion Internet pour télécharger/mettre à jour si nécessaire

---

## 🚀 Lancement

1. **Initialiser l’environnement** (à faire une seule fois) :
   ```
   bash ./LibreStorien_Installation.sh
   ```

2. **Lancer un test IA** :
   ```
   bash ./LibreStorien_TestIA.sh
   ```

---

## 🧪 Exemple de prompt (dans Prompt/1er_prompt.txt)

```
Quelle est votre couleur préférée ?
Quel est votre animal préféré ?
D'où venez-vous ?
Quel est votre plat préféré ?
```

---

## 📂 Organisation attendue des fichiers

```
LibreStorien/
├── Prompt/
│   └── 1er_prompt.txt
├── DATA_Rep/
│   └── <fichiers de réponses>.txt
├── LibreStorien_Installation.sh
├── LibreStorien_TestIA.sh
└── README.md
```

---

## 🔐 Remarques

- Le script ne vérifie pas les droits d'écriture dans les dossiers : lance-le avec un utilisateur ayant les bons droits.
- En cas d’erreur de téléchargement du modèle ou problème réseau, relance simplement le script.

---

## ✨ Auteur

**DURAND Corentin**  
Date : *Avril 2025*
