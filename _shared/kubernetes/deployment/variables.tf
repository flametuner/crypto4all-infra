variable "IMAGE_TAG" {
  description = "The image tag to use for the container"
  default     = ""
}

variable "state_prefix" {
  type = string
}
variable "state_bucket" {
  type = string
}

variable "state_backend" {
  type = string
}

variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "image" {
  type = string
}

variable "args" {
  type    = list(string)
  default = []
}

variable "command" {
  type    = list(string)
  default = []
}

variable "environment" {
  default = "development"
}

variable "environment_vars" {
  type      = map(any)
  sensitive = true
  default   = {}
}

variable "secret_environment_vars" {
  default = {}
}

variable "extra_annotations" {
  default = {}
}

variable "extra_ingress_annotations" {
  default = {}
}

variable "extra_volume_mounts" {
  default = {}

}

variable "extra_volume_secrets" {
  default = {}

}

variable "health_check" {
  type = object({
    path = string
    port = number
  })

  default = {
    path = "/health"
    port = 3000
  }
}

variable "service_account_name" {
  type    = string
  default = ""
}

variable "service_ports" {
  type = list(object({
    name        = string
    port        = number
    target_port = number
  }))
  default = []
}

variable "liveness_delay" {
  type = object({
    period_seconds        = number
    initial_delay_seconds = number
  })

  default = {
    period_seconds        = 30
    initial_delay_seconds = 60
  }
}

variable "replicas" {
  default = 1
}

variable "max_replicas" {
  default = 1
}

variable "requests" {
  type = object({
    memory = string
    cpu    = string
  })

  default = {
    memory = "50Mi"
    cpu    = "10m"
  }
}

variable "limits" {
  type = object({
    memory = string
    cpu    = string
  })

  default = {
    memory = "500Mi"
    cpu    = "250m"
  }
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "enable_liveness" {
  type    = bool
  default = true
}

variable "create_service" {
  type    = bool
  default = true
}

variable "create_ingress" {
  type    = bool
  default = true
}
