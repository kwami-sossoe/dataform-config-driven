#!/bin/bash
set -e # Arrête le script en cas d'erreur

# --- CONFIGURATION ---
PROJECT_ID="itg-data-solutions-fabric-dv"
DATASET="off"
TARGET_TABLE="off_raw_dump"
TEMP_TABLE="temp_loading_$(date +%s)" # Nom unique basé sur le timestamp
BUCKET="off-raw-landing-kss-id-dp-test"
FILENAME="extract.jsonl" # Le fichier à charger

echo "🚀 Démarrage de l'ingestion pour gs://${BUCKET}/${FILENAME}..."

# 1. Chargement dans la table temporaire (Le CSV Hack)
# On charge tout comme une seule chaine de caractères (String)
echo "📦 1. Chargement brut dans ${TEMP_TABLE}..."
bq load \
  --source_format=CSV \
  --field_delimiter="~" \
  --quote="" \
  --autodetect=false \
  "${PROJECT_ID}:${DATASET}.${TEMP_TABLE}" \
  "gs://${BUCKET}/${FILENAME}" \
  raw_line:STRING

# 2. Insertion Transformée dans la table finale
# On parse le JSON et on ajoute la date du jour
echo "🔄 2. Parsing JSON et insertion dans la table finale..."
bq query --use_legacy_sql=false \
"INSERT INTO \`${PROJECT_ID}.${DATASET}.${TARGET_TABLE}\` (ingestion_date, filename, raw_json)
 SELECT
   CURRENT_DATE() as ingestion_date,
   '${FILENAME}' as filename,
   -- CORRECTION ICI : On active le mode 'round' pour les nombres trop précis
   PARSE_JSON(raw_line, wide_number_mode=>'round') as raw_json
 FROM \`${PROJECT_ID}.${DATASET}.${TEMP_TABLE}\`"

# 3. Nettoyage
echo "🧹 3. Suppression de la table temporaire..."
bq rm -f -t "${PROJECT_ID}:${DATASET}.${TEMP_TABLE}"

echo "✅ Succès ! Données ingérées dans ${TARGET_TABLE}."