resource "google_storage_bucket" "data_solutions_terraform_state" {
  name          = "${var.project_id}-tfstate"
  location      = "EU"
  storage_class = "STANDARD"

  project = var.seed_project_id

  versioning {
    enabled = true
  }

  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 10
    }
  }

  # encryption {
  #   default_kms_key_name = "projects/${var.project_id}/locations/EU/keyRings/my-key-ring/cryptoKeys/my-key"
  # }
}

output "tf_state_bucket_name" {
  value       = google_storage_bucket.data_solutions_terraform_state.name
  description = "The name of the tf state bucket"
}
