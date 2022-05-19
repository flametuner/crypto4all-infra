variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "project" {
  type = string
}

variable "permissions" {
  type    = list(string)
  default = []
}

variable "roles" {
  type    = list(string)
  default = []
}
