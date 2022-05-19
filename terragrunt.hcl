
locals {
  current_prefix  = path_relative_to_include()
  google_project  = "crypto-for-all"
  google_location = "us-central1"
}

remote_state {
  backend = "gcs"
  generate = {
    path      = "remote_state.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket   = "cryptoforall-terraform"
    prefix   = local.current_prefix
    location = local.google_location
    project  = local.google_project
  }
}

generate "google_provider" {
  path      = "google_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  project = "${local.google_project}"
  region  = "${local.google_location}"
}

provider "google-beta" {
  project = "${local.google_project}"
  region  = "${local.google_location}"
}
EOF
}

inputs = {
  app_name    = "crypto-for-all"
  location    = local.google_location
  domain_name = "crypto4all.app."
  zone_name   = "crypto4all-app"
}
