terraform {
  source = "${dirname(find_in_parent_folders())}/_shared/kubernetes/certmanager//."
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders())
}

inputs = {
  name = local.root_config.inputs.app_name
  project = local.root_config.locals.google_project
}
