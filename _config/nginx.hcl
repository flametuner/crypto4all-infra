terraform {
  source = "${dirname(find_in_parent_folders())}/_shared/kubernetes/nginx//."
}