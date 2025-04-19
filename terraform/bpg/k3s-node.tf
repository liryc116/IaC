resource "proxmox_virtual_environment_vm" "k3s-node" {
    description = "k3s Node"
    tags        = ["k3s", "node", "nixos"]

    for_each = { for s in local.nodes_flat : index(local.nodes_flat, s) => s }

    name = format("k3s-node-%02d", each.key + 1)
    vm_id = each.key + 2000
    node_name = each.value.node
    on_boot = true

    timeout_clone = 3600
    timeout_migrate = 3600

    agent {
        enabled = true
        type = "virtio"
    }

    clone {
        datastore_id = "extra-disk"
        node_name = "pve"
        vm_id = 9999
        full = true
    }
    cpu {
        cores = 6
        sockets = 1
        type = "host"
    }

    network_device {
        bridge = each.value.bridge
    }

    disk {
        datastore_id = "k8s-drive"
        interface = "scsi0"
        size = 400
    }

    initialization {
        datastore_id = "k8s-drive"
        user_account {
            username = "user"
            keys = [ file("~/.ssh/id_rsa.pub") ]
        }

        ip_config {
            ipv4 {
                address = "dhcp"
            }
        }
    }

    memory {
        dedicated = "16384"
    }

}
