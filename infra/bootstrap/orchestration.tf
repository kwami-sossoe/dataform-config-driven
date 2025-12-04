# --- Cloud Workflows ---

resource "google_workflows_workflow" "off_ingestion" {
  name            = "off-ingestion-pipeline"
  region          = var.region
  description     = "Ingests GCS JSONL to BigQuery and triggers Dataform"
  service_account = google_service_account.workflows_sa.id

  # Ensure the YAML file path is correct relative to where you run terraform
  source_contents = file("${path.module}/../workflows/ingestion.yaml") 

  depends_on = [
    google_project_service.enabled_apis,
    google_project_iam_member.workflows_sa_roles
  ]
}

# --- Eventarc (GCS -> Workflows) ---

resource "google_eventarc_trigger" "gcs_trigger" {
  name     = "trigger-off-upload"
  location = var.region
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  transport {
    pubsub {
      topic = google_pubsub_topic.gcs_events.id
    }
  }
  destination {
    workflow = google_workflows_workflow.off_ingestion.id
  }
  service_account = google_service_account.workflows_sa.email
}
