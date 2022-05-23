
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "env" {
  path = find_in_parent_folders("env.hcl")
}

include "deployment" {
  path = "${dirname(find_in_parent_folders())}/_config/deployment.hcl"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "repository" {
  config_path = "../repository"
}

dependency "domain_record" {
  config_path = "../frontend_record"
}

inputs = {
  name        = "frontend"
  namespace   = dependency.namespace.outputs.name
  image       = "${dependency.repository.outputs.repository_name}/frontend"
  domain_name = dependency.domain_record.outputs.domain_name
}
