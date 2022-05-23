
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

dependency "domain_record" {
  config_path = "../backend_record"
}

dependency "service_account" {
  config_path = "../service_account"
}

inputs = {
  name                 = "backend"
  namespace            = dependency.namespace.outputs.name
  image                = "${dependency.repository.outputs.repository_name}/backend"
  domain_name          = dependency.domain_record.outputs.domain_name
  service_account_name = dependency.service_account.outputs.name
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

    DATABASE_URL = "postgresql://${dependency.database.outputs.username}:${dependency.database.outputs.password}@${dependency.cloudproxy.outputs.name}:5432/${dependency.database.outputs.db_name}?schema=prisma"
    JWT_SECRET   = "***REMOVED***"
    SALT_ROUNDS  = 3
    PORT         = 3000
  }
  requests = {
    cpu    = "10m"
    memory = "80Mi"
  }
}
