terraform {
  source = "${dirname(find_in_parent_folders())}/_shared/google/repository//."
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders())
}

inputs = {
  name     = local.root_config.inputs.app_name
  location = local.root_config.locals.google_location
  project  = local.root_config.locals.google_project
}
