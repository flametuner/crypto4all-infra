
include "root" {
  path = find_in_parent_folders()
}

include "kubernetes" {
  path = "${dirname(find_in_parent_folders())}/_config/kubernetes.hcl"
}

inputs = {
  node_pool = {
    "default" = {
      machine_type   = "e2-small"
      preemptible    = false
      min_node_count = 1
      max_node_count = 1
    }
  }
  location = "us-central1-c"
}
