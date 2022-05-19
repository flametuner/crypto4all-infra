resource "random_id" "db_name_suffix" {
  byte_length = 4
}


resource "google_sql_database_instance" "instance" {
  name             = "${var.name}-${random_id.db_name_suffix.hex}"
  database_version = var.postgres_version


  settings {
    tier = var.db_type
    backup_configuration {
      enabled = true

      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 35
      }
    }
  }
}
