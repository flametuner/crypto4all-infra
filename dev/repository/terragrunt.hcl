
include "root" {
  path   = find_in_parent_folders()
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

include "repository" {
  path = "${dirname(find_in_parent_folders())}/_config/repository.hcl"
}

inputs = {
  name = include.env.inputs.name
}
