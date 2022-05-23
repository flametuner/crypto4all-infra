terraform {
  source = "${dirname(find_in_parent_folders())}/_shared/kubernetes/job//."
}
locals {
  root_config = read_terragrunt_config(find_in_parent_folders())
}

inputs = {
  name = local.root_config.inputs.app_name
  limits = {
    cpu    = "200m"
    memory = "500M"
  }
}
