
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

include "job" {
  path = "${dirname(find_in_parent_folders())}/_config/job.hcl"
}

dependency "database" {
  config_path = "../database"
}

dependency "cloudproxy" {
  config_path = "../cloudproxy"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "repository" {
  config_path = "../repository"
}

dependency "service_account" {
  config_path = "../service_account"
}

inputs = {
  job_name             = "migration"
  namespace            = dependency.namespace.outputs.name
  image                = "${dependency.repository.outputs.repository_name}/migration"
  service_account_name = dependency.service_account.outputs.name
  environment_vars = {
    DATABASE_URL = "postgresql://${dependency.database.outputs.username}:${dependency.database.outputs.password}@${dependency.cloudproxy.outputs.name}:5432/${dependency.database.outputs.db_name}?schema=prisma"
  }
}
