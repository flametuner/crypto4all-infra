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

include "service_account" {
  path = "${dirname(find_in_parent_folders())}/_config/service_account.hcl"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  namespace = dependency.namespace.outputs.name
  roles = [
    "roles/cloudsql.client"
  ]
}
