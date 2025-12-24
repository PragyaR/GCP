resource "google_billing_budget" "budget" {
  billing_account = var.billing_account_id
  display_name    = "SRE Demo Budget"

  amount {
    specified_amount {
      currency_code = "USD"
      units         = 1
    }
  }
}
