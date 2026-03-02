resource "proxmox_virtual_environment_container" "i2p_container" {
  description = "Managed by Terraform"

  node_name = "laptop"
  vm_id     = 1001

  # newer linux distributions require unprivileged user namespaces
  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "i2p-nixos"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        file("~/.ssh/id_rsa.pub")
      ]
      password = random_password.container_password.result
    }
  }

  network_interface {
    name = "veth0"
  }

  disk {
    datastore_id = "local"
    size         = 8
  }

  operating_system {
    template_file_id = "local:vztmpl/nixos-25.11-default_321936167_amd64.tar.xz"
    #template_file_id = proxmox_virtual_environment_download_file.ubuntu_2504_lxc_img.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    type             = "nixos"
  }

}


resource "terraform_data" "bootstrap_ct" {
  count = length(var.ct_bootstrap)

  connection {
    type        = "ssh"
    host        = replace(proxmox_virtual_environment_container.pve_ct.initialization[0].ip_config[0].ipv4[0].address, "/24", "")
    user        = "root"
    private_key = file(var.ct_ssh_privkey)
  }
  provisioner "file" {
    source      = values(var.ct_bootstrap)[count.index].script_path
    destination = "/tmp/bootstrap_script${count.index}.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_script${count.index}.sh",
      join(" ", compact(["/tmp/bootstrap_script${count.index}.sh", try(values(var.ct_bootstrap)[count.index].arguments, [""])])),
    ]
  }

  triggers_replace = [
    time_sleep.wait_for_ct[0].id,
    proxmox_virtual_environment_container.pve_ct.id
  ]

  depends_on = [
    time_sleep.wait_for_ct
  ]
}

resource "random_password" "container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

output "container_password" {
  value     = random_password.container_password.result
  sensitive = true
}
