include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

include "database" {
  path = "${dirname(find_in_parent_folders())}/_config/database.hcl"
}

dependency "cloudsql" {
  config_path = "../cloudsql"
}

inputs = {
  instance_name = dependency.cloudsql.outputs.instance_name
}
