terraform {
  source = "${dirname(find_in_parent_folders())}/_shared/google/database//."
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders())
}

inputs = {
  name = local.root_config.inputs.app_name
}
