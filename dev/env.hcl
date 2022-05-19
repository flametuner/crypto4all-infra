locals {
  env_config  = read_terragrunt_config("${dirname(find_in_parent_folders())}/_env/dev.hcl")
  root_config = read_terragrunt_config(find_in_parent_folders())
}

inputs = merge(local.env_config.inputs, {
  domain_name = "dev.${local.root_config.inputs.domain_name}"
})
