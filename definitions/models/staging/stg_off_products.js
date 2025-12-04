const config = require("includes/config_loader");
const dq = require("includes/data_quality");

// Define Quality Checks
const quality_checks = [
  dq.isValidPer100g("sugars_100g"),
  dq.isValidNutriScore("nutriscore_grade"),
  dq.isValidEnergy("energy_kcal")
];

publish("stg_off_products", {
    ...config.staging.stg_off_products,
    assertions: {
        ...config.staging.stg_off_products.assertions,
        rowConditions: [
            ...(config.staging.stg_off_products.assertions.rowConditions || []),
            ...quality_checks
        ]
    }
})
.query(ctx => `
    SELECT
      ingestion_date,
      filename,

      -- Extraction JSON simple
      JSON_VALUE(raw_json.code) as code,
      TRIM(JSON_VALUE(raw_json.product_name)) as product_name,
      JSON_VALUE(raw_json.brands) as brands,
      LOWER(TRIM(JSON_VALUE(raw_json.main_category))) as main_category,
      
      -- Nutriments
      SAFE_CAST(JSON_VALUE(raw_json.nutriments['energy-kcal_100g']) AS FLOAT64) as energy_kcal,
      SAFE_CAST(JSON_VALUE(raw_json.nutriments['sugars_100g']) AS FLOAT64) as sugars_100g,
      SAFE_CAST(JSON_VALUE(raw_json.nutriments['salt_100g']) AS FLOAT64) as salt_100g,
      
      -- --- CORRECTION CRITIQUE ICI ---
      -- On nettoie la valeur AVANT qu'elle n'arrive dans la table.
      -- Si c'est "", " ", "z", ou n'importe quoi d'autre que A-E, cela devient NULL.
      CASE 
        WHEN UPPER(TRIM(JSON_VALUE(raw_json.nutriscore_grade))) IN ('A', 'B', 'C', 'D', 'E') 
        THEN UPPER(TRIM(JSON_VALUE(raw_json.nutriscore_grade)))
        ELSE NULL 
      END as nutriscore_grade

    FROM
      ${ctx.ref("off_raw_dump")}
    WHERE
      raw_json IS NOT NULL
      
      -- FILTRES OBLIGATOIRES (Pour rejeter les lignes vraiment cassées)
      AND JSON_VALUE(raw_json.code) IS NOT NULL 
      AND LENGTH(TRIM(JSON_VALUE(raw_json.code))) >= 8
      
      AND JSON_VALUE(raw_json.product_name) IS NOT NULL
      AND LENGTH(TRIM(JSON_VALUE(raw_json.product_name))) > 1
      
      AND SAFE_CAST(JSON_VALUE(raw_json.nutriments['sugars_100g']) AS FLOAT64) BETWEEN 0 AND 105
      
      AND SAFE_CAST(JSON_VALUE(raw_json.nutriments['energy-kcal_100g']) AS FLOAT64) >= 0
      AND SAFE_CAST(JSON_VALUE(raw_json.nutriments['energy-kcal_100g']) AS FLOAT64) <= 9000
`);
