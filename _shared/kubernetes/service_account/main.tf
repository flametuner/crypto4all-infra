resource "google_service_account" "this" {
  account_id   = var.name
  display_name = "Service Account for ${var.name}"
}

resource "google_project_iam_member" "role_attach" {
  for_each = toset(var.roles)
  role     = each.key
  member   = "serviceAccount:${google_service_account.this.email}"
  project  = var.project
}

resource "google_project_iam_member" "attachments" {
  count   = length(var.permissions) > 0 ? 1 : 0
  role    = google_project_iam_custom_role.custom_role.0.id
  member  = "serviceAccount:${google_service_account.this.email}"
  project = var.project
}

resource "google_project_iam_custom_role" "custom_role" {
  count       = length(var.permissions) > 0 ? 1 : 0
  role_id     = "${var.name}_role"
  title       = "Custom Role for ${var.name}"
  permissions = var.permissions
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.this.email
    }
  }
}

resource "google_service_account_iam_binding" "gsa_ksa_binding" {
  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project}.svc.id.goog[${var.namespace}/${kubernetes_service_account.this.metadata.0.name}]",
  ]
}
