generate "kubernetes_provider" {
  path      = "kubernetes_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

variable "kubernetes_cluster_name" {}

variable "kubernetes_cluster_location" {}

data "google_client_config" "provider" {}

data "google_container_cluster" "cluster" {
  name     = var.kubernetes_cluster_name
  location = var.kubernetes_cluster_location
}

provider "kubernetes" {
  host  = "https://$${data.google_container_cluster.cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host                   = "https://$${data.google_container_cluster.cluster.endpoint}"
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate,
    )
  }
}
EOF
}

inputs = {
  kubernetes_cluster_name     = "crypto-for-all"
  kubernetes_cluster_location = "us-central1-c"
}
