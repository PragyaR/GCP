# Monitoring configuration for Cloud Run service
resource "google_monitoring_service" "cloudrun" {
  service_id = "${var.service_name}-service"
  display_name = "Demo API Cloud Run Service"

  basic_service {
    service_type = "CLOUD_RUN"
    service_labels = {
      location = var.region
      service_name = var.service_name
    }
  }
}

# Define SLO for availability based on 2xx response codes
resource "google_monitoring_slo" "availability_slo" {
  service = google_monitoring_service.cloudrun.service_id
  slo_id  = "demo-api-availability"

  display_name = "Demo API Availability SLO"

  goal                = 0.999
  rolling_period_days = 30

  request_based_sli {
    good_total_ratio {
      good_service_filter = <<EOT
metric.type="run.googleapis.com/request_count"
resource.type="cloud_run_revision"
metric.label.response_code_class="2xx"
EOT

      total_service_filter = <<EOT
metric.type="run.googleapis.com/request_count"
resource.type="cloud_run_revision"
EOT
    }
  }
}

# Alerting policy for high error rates (5xx responses)
resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "High Error Rate - Demo API"

  combiner = "OR"

  conditions {
    display_name = "5xx error rate > 1%"

    condition_threshold {
      # NUMERATOR: 5xx requests
      filter = <<EOT
metric.type="run.googleapis.com/request_count"
resource.type="cloud_run_revision"
metric.label.response_code_class="5xx"
EOT
      # Alert if error rate > 1% over 2 minutes
      comparison      = "COMPARISON_GT"
      threshold_value = 0.01
      duration        = "120s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }

      # DENOMINATOR: all requests
      denominator_filter = <<EOT
metric.type="run.googleapis.com/request_count"
resource.type="cloud_run_revision"
EOT

      denominator_aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  notification_channels = []                    # Add your notification channel IDs here
}

# Alerting policy for SLO burn rate
resource "google_monitoring_alert_policy" "slo_burn" {
  display_name = "SLO Burn Rate Alert - Demo API"

  conditions {
    display_name = "Fast burn"

    condition_threshold {
      filter = <<EOT
select_slo_burn_rate("projects/${var.project_id}/services/${google_monitoring_service.cloudrun.service_id}/serviceLevelObjectives/${google_monitoring_slo.availability_slo.slo_id}", "60s")
EOT

      comparison      = "COMPARISON_GT"
      threshold_value = 2
      duration        = "120s"
    }
  }

  combiner = "OR"
}