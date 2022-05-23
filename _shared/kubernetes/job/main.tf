terraform {
  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

locals {
  IMAGE_TAG        = var.IMAGE_TAG != "" ? var.IMAGE_TAG : try(data.terraform_remote_state.this.outputs.IMAGE_TAG, "latest")
  environment_vars = var.environment_vars
}

resource "kubernetes_job" "this" {
  metadata {
    name      = "${var.name}-${var.job_name}"
    namespace = var.namespace
  }
  spec {

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

        dynamic "volume" {
          for_each = var.extra_volume_secrets
          content {
            name = volume.key
            secret {
              secret_name = volume.value
            }
          }
        }

        container {
          name              = "${var.name}-${local.IMAGE_TAG}"
          image             = "${var.image}:${local.IMAGE_TAG}"
          image_pull_policy = "Always"
          dynamic "volume_mount" {
            for_each = var.extra_volume_mounts
            content {
              name       = volume_mount.key
              mount_path = volume_mount.value
            }
          }

          dynamic "env" {
            for_each = nonsensitive(keys(local.environment_vars))
            content {
              name  = env.value
              value = local.environment_vars[env.value]
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
        }

        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true
  timeouts {
    create = "10m"
    update = "10m"
  }
}

data "terraform_remote_state" "this" {
  backend = var.state_backend
  config = {
    bucket = var.state_bucket
    prefix = var.state_prefix
  }
}
