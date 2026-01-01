resource "google_service_account" "cloudrun_sa" {
  account_id   = var.service_account_id
  display_name = "Cloud Run SRE Service Account"
}

resource "google_project_iam_member" "logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}