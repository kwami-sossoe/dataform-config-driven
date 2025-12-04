project_id = "itg-data-solutions-fabric-dv"

location                            = "EU"
region                              = "europe-west1"
zone                                = "europe-west1-b"
app_name                            = "retail-benchmark"
cloudbuildv2_github_connection_name = "infra-repo-connection"
apps_repository                     = "cn-apps-services"


env            = "dev"
project_prefix = "off"
env_name       = "development"
dataform_sa    = "custom-dataform-sa"

github_pat_secret_id       = "infra-repo-connection-github-oauthtoken-e584c4"
github_app_installation_id = 13682407

gcs_raw_landing_prefix       = "off-raw-landing"
infra_github_repo_name       = "dataform-config-driven"
infra_default_repo_branch    = "main"
dataform_github_repo_name    = "dataform-config-driven"
dataform_default_repo_branch = "main"
feature_repo_branch          = ".*"
pubsub_topic_name            = "gcs-events"


github_repo_owner           = "kwami-sossoe"
github_token_secret_name    = "DATAFORM_TECHSHARE_GITHUB_PAT"
github_token_secret_version = "latest"

