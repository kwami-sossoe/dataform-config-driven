# 1. The Dataform Repository (Connected to Git)
resource "google_dataform_repository" "repository" {
  provider = google-beta
  project  = var.project_id
  region   = var.region
  name     = var.dataform_repo_name

  git_remote_settings {
    url                                 = "https://github.com/${var.github_repo_owner}/${var.dataform_repo_name}.git"
    default_branch                      = var.github_default_branch
    authentication_token_secret_version = data.google_secret_manager_secret_version.github_pat_version.id
  }

  service_account = google_service_account.dataform_sa.email

  workspace_compilation_overrides {
    default_database = var.project_id
    schema_suffix    = "_suffix"
    table_prefix     = "prefix_"
  }
  
  depends_on = [google_project_service.enabled_apis]
}

# 2. Release Config: Production Compilation
resource "google_dataform_repository_release_config" "release_config" {
  provider      = google-beta
  project       = google_dataform_repository.repository.project
  region        = google_dataform_repository.repository.region
  repository    = google_dataform_repository.repository.name
  name          = "techshare_prj_release"
  git_commitish = "main"
  
  # Daily automatic compilation (Safe guard)
  cron_schedule = "0 7 * * *"
  time_zone     = "Europe/Paris"

  code_compilation_config {
    default_database = var.project_id
    default_schema   = "kss-dataset"
    default_location = var.region
    assertion_schema = "kss-prj-assertion-dataset"
    vars = {
      env = "production"
    }
  }
}

# 3. Dataform Workflow Config (Scheduling)
resource "google_dataform_repository_workflow_config" "workflow" {
  provider       = google-beta
  project        = google_dataform_repository.repository.project
  region         = google_dataform_repository.repository.region
  repository     = google_dataform_repository.repository.name
  name           = "kss-dataform-workflow"
  release_config = google_dataform_repository_release_config.release_config.id

  invocation_config {
    included_tags                            = ["tag_1"]
    transitive_dependencies_included         = true
    transitive_dependents_included           = true
    fully_refresh_incremental_tables_enabled = false
    service_account                          = google_service_account.dataform_sa.email
  }

  cron_schedule = "0 7 * * *"
  time_zone     = "Europe/Paris"
}
