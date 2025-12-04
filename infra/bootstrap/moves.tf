# 1. Migration des APIs GCP (Renommage de la ressource)
moved {
  from = google_project_service.enabled_apis[0]
  to   = google_project_service.enabled_apis["bigquery.googleapis.com"]
}
moved {
  from = google_project_service.enabled_apis[1]
  to   = google_project_service.enabled_apis["dataform.googleapis.com"]
}
moved {
  from = google_project_service.enabled_apis[2]
  to   = google_project_service.enabled_apis["datalineage.googleapis.com"]
}
moved {
  from = google_project_service.enabled_apis[3]
  to   = google_project_service.enabled_apis["iam.googleapis.com"]
}
moved {
  from = google_project_service.enabled_apis[4]
  to   = google_project_service.enabled_apis["pubsub.googleapis.com"]
}
moved {
  from = google_project_service.enabled_apis[5]
  to   = google_project_service.enabled_apis["secretmanager.googleapis.com"]
}
moved {
  from = google_project_service.enabled_apis[6]
  to   = google_project_service.enabled_apis["serviceusage.googleapis.com"]
}
moved {
  from = google_project_service.enabled_apis[7]
  to   = google_project_service.enabled_apis["workflows.googleapis.com"]
}

# 2. Migration des Rôles IAM (Renommage de la ressource)
moved {
  from = google_project_iam_member.multiple_project_roles
  to   = google_project_iam_member.dataform_sa_roles
}

# Dataform Repository (repo -> repository)
moved {
  from = google_dataform_repository.repo
  to   = google_dataform_repository.repository
}

# Dataform Release Config (prod_release -> release_config)
moved {
  from = google_dataform_repository_release_config.prod_release
  to   = google_dataform_repository_release_config.release_config
}
