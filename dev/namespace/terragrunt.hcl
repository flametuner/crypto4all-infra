include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

include "namespace" {
  path = "${dirname(find_in_parent_folders())}/_config/namespace.hcl"
}

inputs = {
  name = "${include.root.inputs.app_name}-${include.env.inputs.environment}"
}
