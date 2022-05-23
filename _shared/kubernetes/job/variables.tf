variable "name" {
  description = "The name of the application"
}

variable "job_name" {
  description = "The name of the job"
  default     = "job"
}

variable "image" {
  type = string
}

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

variable "namespace" {
  default = "default"
}

variable "environment" {
  default = "development"
}

variable "environment_vars" {
  sensitive = true
  type      = map(any)
  default   = {}
}

variable "secret_environment_vars" {
  default = {}
}

variable "extra_annotations" {
  type    = map(string)
  default = {}
}

variable "extra_volume_mounts" {
  type    = map(string)
  default = {}

}

variable "extra_volume_secrets" {
  type    = map(string)
  default = {}
}

variable "service_account_name" {
  type    = string
  default = ""
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