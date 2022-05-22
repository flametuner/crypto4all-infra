terraform {
  source = "${dirname(find_in_parent_folders())}/_shared/kubernetes/deployment//."
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
  health_check = {
    path = "/graphql?query=%7BhealthCheck%7D"
    port = 3000
  }
}
