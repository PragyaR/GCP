# Enable provider-specific linting for Google Cloud
plugin "google" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-google"
  version = "0.34.0"
}

# Enforce explicit Terraform and provider versions
rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

# Reduce noise: allow unused variables during demos
rule "terraform_unused_declarations" {
  enabled = false
}