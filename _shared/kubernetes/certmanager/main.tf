locals {
  credentials_file_name = "key.json"
  command               = <<EOT
cat <<EOF | kubectl --server=https://${data.google_container_cluster.cluster.endpoint} --insecure-skip-tls-verify=true --token=${data.google_client_config.provider.access_token} apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - dns01:
        cloudDNS:
          project: ${var.project}
          serviceAccountSecretRef:
            name: ${kubernetes_secret.cert.metadata.0.name}
            key: ${local.credentials_file_name}
EOF
EOT
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"

  namespace        = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.8.0"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "google_service_account" "service_account" {
  project      = var.project
  account_id   = "dns01-solver-${var.name}"
  display_name = "dns01-solver-${var.name}"
  description  = "solve cert challenges with dns"
}

resource "google_project_iam_member" "dns_admin" {
  project = var.project
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_service_account_key" "service_key" {
  service_account_id = google_service_account.service_account.name
}

resource "kubernetes_secret" "cert" {
  metadata {
    name      = "gcp-${google_service_account.service_account.display_name}-key"
    namespace = "cert-manager"
  }

  data = {
    "${local.credentials_file_name}" = base64decode(google_service_account_key.service_key.private_key)
  }
  depends_on = [
    helm_release.cert_manager
  ]
}


resource "null_resource" "clusterissuer" {

  triggers = {
    project_name    = var.project
    secret_name     = kubernetes_secret.cert.metadata.0.name
    credential_file = local.credentials_file_name
    endpoint        = data.google_container_cluster.cluster.endpoint
    command         = local.command
  }
  provisioner "local-exec" {
    command = local.command
  }
  depends_on = [helm_release.cert_manager]
}
