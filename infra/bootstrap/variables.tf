variable "project_id" {
  type        = string
  description = "The GCP project where resources are created."
}

variable "project_prefix" {
  type        = string
  default     = "kss-id-dp"
  description = "Prefix used for naming resources."
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "Default location for resources (often synonymous with region)"
}

variable "location" {
  type        = string
  description = "Default location for resources (often synonymous with region)"
  default     = "europe-west1"
}

variable "zone" {
  type        = string
  default     = "europe-west1-b"
  description = "The zone for resources."
}

variable "github_repo_owner" {
  type        = string
  default     = "kwami-sossoe" # [cite: 27] Extracted from your URL
  description = "GitHub username or organization."
}

variable "dataform_repo_name" {
  type        = string
  default     = "dataform-config-driven"
  description = "Name for the Dataform repository."
}

variable "github_default_branch" {
  type        = string
  default     = "main"
  description = "Default Git branch."
}

variable "github_token_secret_name" {
  type        = string
  default     = "DATAFORM_TECHSHARE_GITHUB_PAT"
  description = "Name of the EXISTING secret in Secret Manager."
}

variable "github_token_secret_version" {
  type        = string
  default     = "latest"
  description = "Version of the secret."
}

variable "enable_apis" {
  type        = bool
  default     = true
  description = "Toggle to enable necessary APIs."
}
