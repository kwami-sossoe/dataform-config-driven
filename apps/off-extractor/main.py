import os
import json
import time
import requests
import logging
from flask import Flask, request, jsonify
from google.cloud import storage
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)

app = Flask(__name__)

# Default configuration
DEFAULT_PAGE_SIZE = 100
GCS_BUCKET_NAME = os.environ.get("GCS_BUCKET_NAME", "off-raw-landing-default")


@app.route("/", methods=["POST"])
def extract_off_data():
    """
    Extracts OpenFoodFacts data and uploads it to GCS.
    Accepts JSON parameters for manual mode:
    {
        "page_size": 500,
        "country": "france",
        "category": "snacks"
    }
    """
    try:
        # 1. Retrieve parameters (Payload or default)
        params = request.get_json(silent=True) or {}

        page_size = params.get("page_size", DEFAULT_PAGE_SIZE)
        country = params.get("country", "france")

        # Generate filename based on timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"off_extract_{country}_{timestamp}.jsonl"

        logging.info(f"🚀 Starting extraction: Country={country}, Size={page_size}")

        # 2. Call OpenFoodFacts API (MongoDB export format or Search API)
        # For this example, we use the simplified Search API
        url = f"https://{country}.openfoodfacts.org/cgi/search.pl"
        query_params = {
            "search_simple": 1,
            "action": "process",
            "json": 1,
            "page_size": page_size,
            "page": 1,
        }

        # Add category filter if present
        if "category" in params:
            query_params["tagtype_0"] = "categories"
            query_params["tag_contains_0"] = "contains"
            query_params["tag_0"] = params["category"]

        response = requests.get(url, params=query_params, timeout=30)
        response.raise_for_status()

        data = response.json()
        products = data.get("products", [])

        if not products:
            logging.warning("No products found")
            return jsonify({"status": "warning", "message": "No products found"}), 200

        # 3. Convert to JSONL (Newline Delimited JSON)
        # This is the ideal format for BigQuery
        jsonl_content = ""
        for product in products:
            # Add technical metadata
            product["_extracted_at"] = timestamp
            jsonl_content += json.dumps(product) + "\n"

        # 4. Upload to GCS
        client = storage.Client()
        bucket = client.bucket(GCS_BUCKET_NAME)
        blob = bucket.blob(filename)

        blob.upload_from_string(jsonl_content, content_type="application/json")

        logging.info(f"✅ File uploaded: gs://{GCS_BUCKET_NAME}/{filename}")

        return jsonify(
            {
                "status": "success",
                "gcs_uri": f"gs://{GCS_BUCKET_NAME}/{filename}",
                "products_count": len(products),
                "params_used": params,
            }
        ), 200

    except Exception as e:
        logging.error(f"❌ Error: {str(e)}")
        return jsonify({"status": "error", "error": str(e)}), 500


if __name__ == "__main__":
    # Local development
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
