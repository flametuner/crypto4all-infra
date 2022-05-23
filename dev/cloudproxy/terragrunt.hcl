
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

dependency "cloudsql" {
  config_path = "../cloudsql"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "service_account" {
  config_path = "../service_account"
}

inputs = {
  name                 = "cloud-proxy"
  namespace            = dependency.namespace.outputs.name
  image                = "gcr.io/cloudsql-docker/gce-proxy"
  IMAGE_TAG            = "1.30.1"
  command              = ["/cloud_sql_proxy", "-log_debug_stdout", "-instances=${include.root.locals.google_project}:${include.root.locals.google_location}:${dependency.cloudsql.outputs.instance_name}=tcp:5432"]
  service_account_name = dependency.service_account.outputs.name
  create_ingress       = false
  create_service       = true
  enable_liveness      = false
  service_ports = [
    {
      name        = "postgres"
      port        = 5432
      target_port = 5432
    }
  ]
}
