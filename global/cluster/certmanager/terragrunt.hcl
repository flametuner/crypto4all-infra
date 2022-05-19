include "root" {
  path = find_in_parent_folders()
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "certmanager" {
    path = "${dirname(find_in_parent_folders())}/_config/certmanager.hcl"
}