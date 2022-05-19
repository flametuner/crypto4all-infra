include "root" {
  path = find_in_parent_folders()
}

dependency "nginx" {
  config_path = "${dirname(find_in_parent_folders())}/global/cluster/nginx"
}

include "dns_record" {
  path = "${dirname(find_in_parent_folders())}/_config/dns_record.hcl"
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

inputs = {
  record_name  = "api.${include.env.inputs.domain_name}"
  record_type  = "A"
  record_value = dependency.nginx.outputs.external_loadbalancer_ip
}
