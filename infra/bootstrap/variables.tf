variable "project_id" {
  type        = string
  description = "The GCP project where resources are created."
}


variable "env" {
  type        = string
  description = "The environment prefix."
}

variable "env_name" {
  type        = string
  description = "Name of the environment."
}

variable "app_name" {
  type        = string
  description = "Name of the application."
}

variable "seed_project_id" {
  type        = string
  description = "The seed GCP project for the terraform state backend."
  default     = "cloud-insights-data-lab"
}


variable "project_prefix" {
  type        = string
  description = "Prefix used for naming resources."
}

variable "region" {
  type        = string
  description = "Default location for resources (often synonymous with region)"
}

variable "location" {
  type        = string
  description = "Default location for resources (often synonymous with region)"
}

variable "zone" {
  type        = string
  description = "The zone for resources."
}

variable "github_repo_owner" {
  type        = string
  description = "GitHub username or organization."
}


variable "infra_github_repo_name" {
  type        = string
  description = "Name for the Infrastructure repository."
}

variable "gcs_raw_landing_prefix" {
  type        = string
  description = "Prefix for GCS raw landing buckets."
}


variable "github_token_secret_name" {
  type        = string
  description = "Name of the EXISTING secret in Secret Manager."
}

variable "github_pat_secret_id" {
  type        = string
  description = "Name of the EXISTING secret in Secret Manager."
}


variable "github_token_secret_version" {
  type        = string
  description = "Version of the secret."
}

variable "pubsub_topic_name" {
  type        = string
  description = "Name of the Pub/Sub topic for GCS events."
}
variable "enable_apis" {
  type        = bool
  default     = true
  description = "Toggle to enable necessary APIs."
}

variable "github_app_installation_id" {
  type        = number
  description = "GitHub App Installation ID for Cloud Build connection."
}


variable "dataform_github_repo_name" {
  type        = string
  description = "Name for the Dataform repository."
}

variable "dataform_default_repo_branch" {
  type        = string
  description = "Branch name for the Dataform repository."
}

variable "dataform_sa" {
  type        = string
  description = "Custom Dataform Service Account name."
}
variable "feature_repo_branch" {
  type        = string
  description = "Regex pattern for feature branches."
}

variable "infra_default_repo_branch" {
  type        = string
  description = "Default branch name for the Infrastructure repository."
}

variable "cloudbuildv2_github_connection_name" {
  type        = string
  description = "Name of the Cloud Build GitHub connection."
}

variable "apps_repository" {
  type        = string
  description = "Name of the Artifact Registry repository for cloud native services."
}
