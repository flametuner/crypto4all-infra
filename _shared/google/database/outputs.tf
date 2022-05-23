

output "hostname" {
  value = data.google_sql_database_instance.instance.private_ip_address
}

output "db_name" {
  value = google_sql_database.database.name
}

output "username" {
  value = google_sql_user.user.name
}

output "password" {
  value     = google_sql_user.user.password
  sensitive = true
}
