variable "nodes" {
    description = "List of workers to deploy"
    type = map(any)
    default = {
        pve = {
            node = "pve"
            bridge = "vmbr1"
            count = 2
        },
        node_name = {
            node = "node's name in PVE"
            bridge = "node's bridge"
            count = number of VM to deploy
        }
    }
}

locals {
  nodes_flat = flatten([
    for s in var.nodes: [
      for n in range(s.count) : {
        node  = s.node
        bridge  = s.bridge
        index = n
      }
    ]
  ])
}
