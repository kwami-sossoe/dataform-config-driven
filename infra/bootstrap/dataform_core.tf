# 1. The Dataform Repository (Connected to Git)
resource "google_dataform_repository" "repository" {
  provider = google-beta
  project  = var.project_id
  region   = var.region
  name     = var.dataform_github_repo_name

  git_remote_settings {
    url                                 = "https://github.com/${var.github_repo_owner}/${var.dataform_github_repo_name}.git"
    default_branch                      = var.dataform_default_repo_branch
    authentication_token_secret_version = data.google_secret_manager_secret_version.github_pat_version.id
  }

  service_account = google_service_account.env_dataform_sa.email

  workspace_compilation_overrides {
    default_database = var.project_id
    schema_suffix    = "_suffix"
    table_prefix     = "prefix_"
  }

  depends_on = [
    google_project_service.enabled_apis,
    google_project_iam_member.env_dataform_sa_roles,
  ]
}

# 2. Release Config: Production Compilation
resource "google_dataform_repository_release_config" "release_config" {
  provider      = google-beta
  project       = google_dataform_repository.repository.project
  region        = google_dataform_repository.repository.region
  repository    = google_dataform_repository.repository.name
  name          = "${var.project_prefix}-prj-release-${var.env}"
  git_commitish = var.dataform_default_repo_branch

  # Daily automatic compilation (Safe guard)
  cron_schedule = "0 7 * * *"
  time_zone     = "Europe/Paris"

  code_compilation_config {
    default_database = var.project_id
    default_schema   = "${var.project_prefix}-schema-${var.env}"
    default_location = var.region
    assertion_schema = "${var.project_prefix}-assertion-schema-${var.env}"
    vars = {
      env = var.env_name
    }
  }
}

# 3. Dataform Workflow Config (Scheduling)
resource "google_dataform_repository_workflow_config" "workflow" {
  provider       = google-beta
  project        = google_dataform_repository.repository.project
  region         = google_dataform_repository.repository.region
  repository     = google_dataform_repository.repository.name
  name           = "${var.project_prefix}-dataform-workflow-${var.env}"
  release_config = google_dataform_repository_release_config.release_config.id

  invocation_config {
    included_tags                            = ["${var.project_prefix}"]
    transitive_dependencies_included         = true
    transitive_dependents_included           = true
    fully_refresh_incremental_tables_enabled = false
    service_account                          = google_service_account.env_dataform_sa.email
  }

  cron_schedule = "0 7 * * *"
  time_zone     = "Europe/Paris"
}
