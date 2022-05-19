resource "google_artifact_registry_repository" "this" {
  provider = google-beta

  location      = var.location
  project       = var.project
  
  repository_id = var.name
  description   = var.description
  format        = "DOCKER"
}
