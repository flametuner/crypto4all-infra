output "domain_name" {
  value = replace(google_dns_record_set.dns.name, "/[.]$/", "")
}
