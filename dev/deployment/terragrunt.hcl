
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
    BNB_TESTNET_RPC      = "https://data-seed-prebsc-1-s3.binance.org:8545/"
    TWITTER_BEARER_TOKEN = "[REMOVED]"
    PRIVATE_KEY          = "[REMOVED]"
    DATABASE_URL         = "postgresql://${dependency.database.outputs.username}:${dependency.database.outputs.password}@${dependency.cloudproxy.outputs.name}:5432/${dependency.database.outputs.db_name}?schema=prisma"
    JWT_SECRET           = "[REMOVED]"
    PORT                 = 3000
  }
  requests = {
    cpu    = "10m"
    memory = "80Mi"
  }
}
