terraform {
  source = "${dirname(find_in_parent_folders())}/_shared/google/dns_record//."
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders())
}

inputs = {
  project = local.root_config.locals.google_project
}
