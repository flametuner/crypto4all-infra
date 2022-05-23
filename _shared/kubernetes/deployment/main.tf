terraform {
  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
locals {
  env_keys  = nonsensitive(keys(var.environment_vars))
  IMAGE_TAG = var.IMAGE_TAG != "" ? var.IMAGE_TAG : try(data.terraform_remote_state.this.outputs.IMAGE_TAG, "latest")
}

data "terraform_remote_state" "this" {
  backend = var.state_backend
  config = {
    bucket = var.state_bucket
    prefix = var.state_prefix
  }
}


resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app         = var.name
      environment = var.environment
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app         = var.name
        environment = var.environment
      }
    }

    template {
      metadata {
        labels = {
          app         = var.name
          environment = var.environment
        }
        annotations = merge({
          "co.elastic.logs/enabled" = "true"
        }, var.extra_annotations)
      }

      spec {
        service_account_name = var.service_account_name

        node_selector = {
          "iam.gke.io/gke-metadata-server-enabled" = "true"
        }

        dynamic "volume" {
          for_each = var.extra_volume_secrets
          content {
            name = volume.key
            secret {
              secret_name = volume.value
            }
          }
        }

        dynamic "container" {
          for_each = length(var.cloudsql_sidecar_instance) > 0 ? [var.cloudsql_sidecar_instance] : []

          content {
            image   = "gcr.io/cloudsql-docker/gce-proxy:1.30.1"
            name    = "cloudsql-proxy"
            command = ["/cloud_sql_proxy", "-log_debug_stdout", "-instances=${container.value}=tcp:5432"]
            security_context {
              run_as_non_root = true
            }
          }
        }

        container {
          image = "${var.image}:${local.IMAGE_TAG}"
          name  = var.name
          args  = var.args

          dynamic "volume_mount" {
            for_each = var.extra_volume_mounts
            content {
              name       = volume_mount.key
              mount_path = volume_mount.value
            }
          }

          dynamic "env" {
            for_each = local.env_keys
            content {
              name  = env.value
              value = var.environment_vars[env.value]
            }
          }
          dynamic "env" {
            for_each = var.secret_environment_vars
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = env.value.name
                  key  = env.value.key
                }
              }
            }
          }

          resources {
            limits   = var.limits
            requests = var.requests
          }

          dynamic "liveness_probe" {
            for_each = var.enable_liveness ? [var.liveness_delay] : []
            content {
              http_get {
                path = var.health_check.path
                port = var.health_check.port
              }

              initial_delay_seconds = liveness_probe.value.initial_delay_seconds
              period_seconds        = liveness_probe.value.period_seconds
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "this" {
  count = var.max_replicas > var.replicas ? 1 : 0
  metadata {
    name      = "${var.name}-autoscaler"
    namespace = var.namespace
    labels = {
      app         = var.name
      environment = var.environment
    }
  }

  spec {
    max_replicas = var.max_replicas
    min_replicas = var.replicas

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.deployment.metadata.0.name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  count = var.create_service ? 1 : 0
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  spec {
    selector = {
      app         = var.name
      environment = var.environment
    }
    # session_affinity = "ClientIP"
    dynamic "port" {
      for_each = var.enable_liveness ? [var.health_check] : []
      content {
        name        = "http"
        port        = port.value.port
        target_port = port.value.port
      }
    }

    dynamic "port" {
      for_each = var.service_ports
      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
      }
    }

    # type = "LoadBalancer"
  }
}

resource "kubernetes_ingress" "ingress" {
  count = var.create_ingress && var.create_service ? 1 : 0
  metadata {
    name      = "${var.name}-ingress"
    namespace = var.namespace
    annotations = merge({
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }, var.extra_ingress_annotations)
  }

  spec {
    rule {
      host = var.domain_name
      http {
        path {
          backend {
            service_name = kubernetes_service.service[0].metadata[0].name
            service_port = var.health_check.port
          }
        }
      }
    }

    tls {
      hosts       = [var.domain_name]
      secret_name = "${var.name}-tls-secret"
    }
  }
}
