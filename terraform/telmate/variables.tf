variable "servers" {
    description = "List of server where to deploy"
    type = map(any)
    default = {
        pve = {
            node = "pve"
            bridge = "vmbr0"
            count = 2
        },
        /*
        node_name = {
            node = "node's name in PVE"
            bridge = "node's bridge"
            count = number of VM to deploy to the node
        }
        */
    }
}

locals {
  servers_flat = flatten([
    for s in var.servers : [
      for n in range(s.count) : {
        node  = s.node
        bridge  = s.bridge
        index = n
      }
    ]
  ])
}
