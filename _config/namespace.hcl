terraform {
  source = "${dirname(find_in_parent_folders())}/_shared/kubernetes/namespace//."
}

locals {
  app = read_terragrunt_config(find_in_parent_folders())
}

inputs = {
  name = local.app.inputs.app_name
}
