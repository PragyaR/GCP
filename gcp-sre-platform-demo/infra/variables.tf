variable "project_id" {
  description = "GCP project ID (e.g. my-gcp-project)"
  type        = string
}
variable "region" {
  default = "us-central1"
}
variable "service_name" {
  default = "demo-api"
}
variable "billing_account_id" {
  description = "GCP billing account ID (e.g. 000000-000000-000000)"
  type        = string
}
variable "service_account_id" {
  description = "GCP service account ID (e.g. cloudrun-sre)"
  type        = string
  default     = "cloudrun-sre"
}