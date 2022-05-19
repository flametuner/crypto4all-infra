
resource "google_dns_managed_zone" "this" {
  name        = var.name
  dns_name    = var.dns_name
  description = var.description
}
