variable "name" {
  description = "Application name used for identification"
}

variable "db_type" {
  description = "Database type"
  default     = "db-f1-micro"
}

variable "postgres_version" {
  description = "Postgres version"
  default     = "POSTGRES_13"
}
