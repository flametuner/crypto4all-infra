
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "clouddns" {
  path = "${dirname(find_in_parent_folders())}/_config/clouddns.hcl"
}

inputs = {
  name     = include.root.inputs.zone_name
  dns_name = include.root.inputs.domain_name
}
