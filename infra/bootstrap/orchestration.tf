resource "google_workflows_workflow" "off_ingestion" {
  name            = "off-ingestion-pipeline-${var.env}"
  region          = var.region
  description     = "Ingests GCS JSONL to BigQuery and triggers Dataform"
  service_account = google_service_account.workflows_sa.id

  source_contents = file("${path.module}/../orchestration/ingestion.yaml")

  depends_on = [
    google_project_service.enabled_apis,
    google_project_iam_member.workflows_sa_roles
  ]
}

resource "google_eventarc_trigger" "gcs_trigger" {
  name     = "trigger-off-upload-${var.env}"
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

resource "google_cloudbuildv2_connection" "github_connection" {
  location = var.region
  name     = var.cloudbuildv2_github_connection_name

  github_config {
    app_installation_id = var.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = "projects/${var.project_id}/secrets/${var.github_pat_secret_id}/versions/latest"
    }
  }
  depends_on = [google_project_service.enabled_apis]
}

resource "google_cloudbuildv2_repository" "infra_repo" {
  location          = var.region
  name              = var.infra_github_repo_name
  parent_connection = google_cloudbuildv2_connection.github_connection.name
  remote_uri        = "https://github.com/${var.github_repo_owner}/${var.infra_github_repo_name}.git"
}

resource "google_cloudbuild_trigger" "infra_deploy" {
  name        = "infra-dataform-deployer"
  location    = var.region
  description = "TF Infras Deployer for Dataform Data Stack."

  service_account = "projects/${var.project_id}/serviceAccounts/kss-dataform-sa@itg-data-solutions-fabric-dv.iam.gserviceaccount.com"
  # "projects/${var.project_id}/serviceAccounts/${google_service_account.env_dataform_sa.email}"

  repository_event_config {
    repository = google_cloudbuildv2_repository.infra_repo.id
    push {
      branch = "^${var.infra_default_repo_branch}$"
    }
  }

  filename = "bootstrap/orchestration/infra_cloudbuild.yaml"

  depends_on = [
    google_cloudbuildv2_repository.infra_repo,
    google_project_iam_member.env_dataform_sa_roles,
    google_cloudbuildv2_connection.github_connection,
  ]
}
