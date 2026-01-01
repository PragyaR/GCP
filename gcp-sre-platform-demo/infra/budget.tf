resource "google_billing_budget" "budget" {
  billing_account = var.billing_account_id
  display_name    = "SRE Demo Budget"

  amount {
    specified_amount {
      currency_code = "USD"
      units         = 1
    }
  }

  threshold_rules {
    threshold_percent = 0.5
  }

  threshold_rules {
    threshold_percent = 0.9
  }

  threshold_rules {
    threshold_percent = 1.0
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.email.id
    ]
    disable_default_iam_recipients = false
  }
}
resource "google_monitoring_notification_channel" "email" {
  display_name = "SRE Demo Budget Email"
  type         = "email"
  labels = {
    email_address = "sre-demo-budget@example.com" # Replace with your email address to send notifications to this email
  }
}