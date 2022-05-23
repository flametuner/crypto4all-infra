
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

dependency "cloudsql" {
  config_path = "../cloudsql"
}

dependency "database" {
  config_path = "../database"
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
  job_name                  = "migration"
  namespace                 = dependency.namespace.outputs.name
  image                     = "${dependency.repository.outputs.repository_name}/migration"
  cloudsql_sidecar_instance = "${include.root.locals.google_project}:${include.root.locals.google_location}:${dependency.cloudsql.outputs.instance_name}"
  service_account_name      = dependency.service_account.outputs.name
  environment_vars = {
    DATABASE_URL = "postgresql://${dependency.database.outputs.username}:${dependency.database.outputs.password}@localhost:5432/${dependency.database.outputs.db_name}?schema=prisma"
  }
}
