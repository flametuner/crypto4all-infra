terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

data "google_sql_database_instance" "instance" {
  name = var.instance_name
}

resource "google_sql_database" "database" {
  name     = var.name
  instance = data.google_sql_database_instance.instance.name
}

resource "google_sql_user" "user" {
  name     = var.name
  instance = data.google_sql_database_instance.instance.name
  password = random_password.password.result
}

resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = "_%@"
}
