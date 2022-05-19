
resource "google_service_account" "default" {
  account_id   = "k8s-${var.name}-sa"
  display_name = "Default ${var.name} Service Account"
}

resource "google_container_cluster" "primary" {
  name     = var.name
  location = var.location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.name}.svc.id.goog"
  }
}

resource "google_container_node_pool" "node_pool" {
  for_each = var.node_pool
  name     = each.key
  location = var.location
  cluster  = google_container_cluster.primary.name
  autoscaling {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }

  node_config {
    preemptible  = each.value.preemptible
    machine_type = each.value.machine_type
    disk_type    = "pd-ssd"
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

}
