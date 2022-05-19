
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

include "cloudsql" {
  path = "${dirname(find_in_parent_folders())}/_config/cloudsql.hcl"
}

inputs = {
  name = "${include.root.inputs.app_name}-${include.env.inputs.environment}"
}
