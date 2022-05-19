
include "root" {
  path = find_in_parent_folders()
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

dependency "repository" {
  config_path = "../repository"
}

dependency "domain_record" {
  config_path = "../backend_record"
}

dependency "service_account" {
  config_path = "../service_account"
}

inputs = {
  namespace                 = dependency.namespace.outputs.name
  image                     = "${dependency.repository.outputs.repository_name}/app:latest"
  domain_name               = dependency.domain_record.outputs.domain_name
  cloudsql_sidecar_instance = "${include.root.locals.google_project}:${include.root.locals.google_location}:${dependency.cloudsql.outputs.instance_name}"
  service_account_name      = dependency.service_account.outputs.name
  environment_vars = {
    API_URL_RINKEBY = "***REMOVED***"
    API_URL_MUMBAI  = "https://polygon-mumbai.infura.io/v3/***REMOVED***"

    PRIVATE_KEY_RINKEBY = "***REMOVED***"
    PRIVATE_KEY_MUMBAI  = "***REMOVED***"

    MY_ADDRESS_RINKEBY = "***REMOVED***"
    MY_ADDRESS_MUMBAI  = "***REMOVED***"


    INFURA_PROJECT_ID     = "***REMOVED***"
    INFURA_PROJECT_SECRET = "***REMOVED***"

    TWITTER_CONSUMER_KEY    = "***REMOVED***"
    TWITTER_CONSUMER_SECRET = "***REMOVED***"
    TWITTER_BEARER_TOKEN    = "***REMOVED***"

    DATABASE_URL = "postgresql://postgres:postgres@localhost:5432/dev?schema=prisma"
    JWT_SECRET   = "***REMOVED***"
    SALT_ROUNDS  = 3
  }
}
