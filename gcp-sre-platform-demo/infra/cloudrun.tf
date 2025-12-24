resource "google_cloud_run_service" "api" {
  name     = var.service_name
  location = var.region
  depends_on = [
    google_project_service.required_apis
  ]
  template {
    spec {
      service_account_name = google_service_account.cloudrun_sa.email
      containers {
        image = "gcr.io/${var.project_id}/${var.service_name}:latest"

        env {
          name  = "ERROR_RATE"
          value = "0.02"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public" {
  service  = google_cloud_run_service.api.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
