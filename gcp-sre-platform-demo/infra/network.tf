# Unsused file to demonstrate VPC creation
resource "google_compute_network" "vpc" {
  name                    = "sre-vpc"
  auto_create_subnetworks = true
}
