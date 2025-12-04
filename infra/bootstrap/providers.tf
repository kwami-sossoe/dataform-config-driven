terraform {
  required_version = ">= 1.13.5"
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.12.0, < 8.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.12.0, < 8.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
