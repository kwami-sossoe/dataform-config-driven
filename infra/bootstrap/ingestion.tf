resource "google_artifact_registry_repository" "cn_apps_repo" {
  project       = var.seed_project_id
  provider      = google-beta
  location      = var.region
  repository_id = var.apps_repository
  description   = "Docker repository for cloud native services"
  format        = "DOCKER"
}


resource "google_service_account" "extractor_sa" {
  account_id   = "${var.project_prefix}-extractor-sa-${var.env}"
  display_name = "OFF Extractor Service Account"
  description  = "Identity for the Cloud Run extraction service"
}

resource "google_storage_bucket_iam_member" "extractor_gcs_writer" {
  bucket = google_storage_bucket.landing_zone.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.extractor_sa.email}"
}

resource "google_cloud_run_v2_service" "extractor" {
  name     = "${var.project_prefix}-extractor-service-${var.env}"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.extractor_sa.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.cn_apps_repo.name}/off-extractor:latest"

      env {
        name  = "GCS_BUCKET_NAME"
        value = google_storage_bucket.landing_zone.name
      }

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version
    ]
  }

  depends_on = [
    google_storage_bucket_iam_member.extractor_gcs_writer,
  ]
}


resource "google_service_account" "scheduler_sa" {
  account_id   = "scheduler-sa-${var.env}"
  display_name = "Cloud Scheduler Service Account"
}

resource "google_cloud_run_service_iam_member" "scheduler_invoker" {
  service  = google_cloud_run_v2_service.extractor.name
  location = google_cloud_run_v2_service.extractor.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler_sa.email}"
}

# Scheduled Job : Daily at 05:00 am Paris time
resource "google_cloud_scheduler_job" "daily_extraction" {
  name        = "daily-off-extraction"
  description = "Trigger Daily extraction of OFF data to GCS"
  schedule    = "0 5 * * *"
  time_zone   = "Europe/Paris"
  region      = var.region

  http_target {
    http_method = "POST"
    uri         = google_cloud_run_v2_service.extractor.uri

    # Default parameter for every day extraction
    body = base64encode(jsonencode({
      "page_size" : 1000,
      "country" : "france"
    }))

    headers = {
      "Content-Type" = "application/json"
    }

    # Secured OIDC Authentification
    oidc_token {
      service_account_email = google_service_account.scheduler_sa.email
    }
  }
}
