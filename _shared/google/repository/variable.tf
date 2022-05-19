variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = "Terraform Managed Repository"
}

variable "project" {
  type = string
}

variable "location" {
  type    = string
  default = "us-central1"
}
