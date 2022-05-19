
variable "name" {

}

variable "location" {

}


variable "node_pool" {

  type = map(object({
    machine_type   = string
    preemptible    = bool
    min_node_count = number
    max_node_count = number
  }))

}
