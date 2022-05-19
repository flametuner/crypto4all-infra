terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}


data "google_dns_managed_zone" "zone" {
  name    = var.zone_name
  project = var.project
}

resource "google_dns_record_set" "dns" {
  name    = var.record_name
  project = var.project
  type    = var.record_type
  ttl     = var.record_ttl

  managed_zone = data.google_dns_managed_zone.zone.name

  rrdatas = [var.record_value]
}
