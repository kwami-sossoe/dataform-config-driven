# --- Data Sources ---
data "google_project" "project" {
  project_id = var.project_id
}

data "google_storage_project_service_account" "gcs_account" {}

data "google_secret_manager_secret_version" "github_pat_version" {
  project = var.project_id
  secret  = var.github_token_secret_name
  version = var.github_token_secret_version
}

# --- Service Accounts ---

resource "google_service_account" "env_dataform_sa" {
  provider     = google-beta
  project      = var.project_id
  account_id   = "${var.dataform_sa}-${var.env}"
  display_name = "Custom Dataform Service Account"
}


resource "google_service_account" "workflows_sa" {
  account_id   = "workflows-sa"
  display_name = "Workflows Service Account"
}

# Identity for Workflows (Prevents destroy of google_project_service_identity)
resource "google_project_service_identity" "workflows_agent" {
  provider = google-beta
  service  = "workflows.googleapis.com"
}

# --- IAM Bindings ---

locals {
  apis_to_enable = [
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "bigquery.googleapis.com",
    "dataform.googleapis.com",
    "secretmanager.googleapis.com",
    "workflows.googleapis.com",
    "datalineage.googleapis.com",
    "pubsub.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudscheduler.googleapis.com",
  ]

  roles_to_grant_to_custom_dataform_sa = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/storage.objectViewer",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/dataform.editor",
    "roles/workflows.invoker",
    "roles/logging.logWriter",
    "roles/dataform.serviceAgent",
    "roles/cloudbuild.connectionAdmin",
    "roles/cloudbuild.readTokenAccessor",
    "roles/logging.logWriter",
    "roles/storage.objectViewer",
    "roles/artifactregistry.writer",
    "roles/cloudbuild.builds.editor",
  ]

  # Roles for the DEFAULT Google Service Agents (restored to prevent destroys)
  roles_to_grant_to_default_dataform_sa = [
    "roles/iam.serviceAccountTokenCreator",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountUser",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/pubsub.publisher",
  ]
}

resource "google_project_service" "enabled_apis" {
  provider           = google-beta
  for_each           = var.enable_apis ? toset(local.apis_to_enable) : []
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# Grant roles to Custom Dataform SA
resource "google_project_iam_member" "env_dataform_sa_roles" {
  for_each = toset(local.roles_to_grant_to_custom_dataform_sa)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.env_dataform_sa.email}"
}

# Grant roles to Workflows SA
resource "google_project_iam_member" "workflows_sa_roles" {
  for_each = toset([
    "roles/dataform.editor",
    "roles/bigquery.jobUser",
    "roles/bigquery.dataEditor",
    "roles/storage.objectViewer",
    "roles/logging.logWriter"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.workflows_sa.email}"
}

resource "google_service_account_iam_member" "cloudbuild_act_as_workflows" {
  service_account_id = google_service_account.workflows_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "default_dataform_sa_project_roles" {
  for_each = toset(local.roles_to_grant_to_default_dataform_sa)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "default_dataform_sa_project_role_2" {
  for_each = toset(local.roles_to_grant_to_default_dataform_sa)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}
