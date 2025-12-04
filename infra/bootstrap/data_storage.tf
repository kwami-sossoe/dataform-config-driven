resource "google_storage_bucket" "landing_zone" {
  name                        = "${var.gcs_raw_landing_prefix}-${var.project_id}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "landing_zone_test" {
  name                        = "${var.gcs_raw_landing_prefix}-${var.project_prefix}-test"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_pubsub_topic" "gcs_events" {
  name    = var.pubsub_topic_name
  project = var.project_id
}

resource "google_pubsub_topic_iam_member" "gcs_publisher" {
  topic  = google_pubsub_topic.gcs_events.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

resource "google_storage_notification" "bucket_notification" {
  bucket         = google_storage_bucket.landing_zone.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.gcs_events.id
  event_types    = ["OBJECT_FINALIZE"]
  depends_on     = [google_pubsub_topic_iam_member.gcs_publisher]
}

resource "google_bigquery_dataset" "off_dataset" {
  dataset_id                 = "off"
  friendly_name              = "Open Food Facts Raw Data"
  description                = "Dataset containing raw dumps and staging tables."
  location                   = var.region
  delete_contents_on_destroy = true

  labels = {
    env = var.env_name
    app = var.app_name
  }
}

resource "google_bigquery_table" "off_raw_dump" {
  dataset_id          = google_bigquery_dataset.off_dataset.dataset_id
  table_id            = "off_raw_dump"
  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "ingestion_date"
  }
  clustering = ["filename"]

  # Schema-on-read pattern: Everything goes into 'raw_json'
  schema = <<EOF
[
  { "name": "ingestion_date", "type": "DATE", "mode": "REQUIRED" },
  { "name": "filename", "type": "STRING", "mode": "NULLABLE" },
  { "name": "raw_json", "type": "JSON", "mode": "NULLABLE" }
]
EOF
}
