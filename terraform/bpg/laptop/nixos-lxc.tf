locals {
  # Helper to determine if a container needs a random password
  containers_needing_pw = {
    for k, v in var.containers : k => v
    if v.ct_user.password == null && v.ct_type == "template"
  }

  # Flattening bootstrap files for the provisioner to handle nested lists
  bootstrap_tasks = flatten([
    for ct_key, ct in var.containers : [
      for i, file_path in ct.ct_bootstrap : {
        id     = "${ct_key}-${i}"
        ct_key = ct_key
        file   = file_path
      }
    ]
  ])

  # Flattening copy tasks
  copy_tasks = flatten([
    for ct_key, ct in var.containers : [
      for i, config in ct.ct_copy_files : {
        id     = "${ct_key}-${i}"
        ct_key = ct_key
        src    = config.src
        dst    = config.dst
      }
    ]
  ])
}

# 1. Generate passwords for each container that needs one
resource "random_password" "ct_root_pw" {
  for_each         = local.containers_needing_pw
  override_special = "_%@"
  special          = true
  length           = 30
}

# 2. The Main Container Resource
resource "proxmox_virtual_environment_container" "pve_ct" {
  for_each = var.containers

  node_name = var.pve_node

  # CT Information
  tags         = each.value.ct_tags
  vm_id        = each.value.ct_id
  pool_id      = each.value.ct_pool
  unprivileged = each.value.ct_unprivileged
  protection   = each.value.ct_protection
  template     = each.value.ct_template

  started       = each.value.ct_start.on_deploy
  start_on_boot = each.value.ct_start.on_boot

  startup {
    order      = each.value.ct_start.order
    up_delay   = each.value.ct_start.up_delay
    down_delay = each.value.ct_start.down_delay
  }

  dynamic "clone" {
    for_each = (each.value.ct_type == "clone") ? ["enabled"] : []
    content {
      datastore_id = each.value.src_clone.datastore_id
      node_name    = (each.value.src_clone.node_name != null) ? each.value.src_clone.node_name : var.pve_node
      vm_id        = each.value.src_clone.tpl_id
    }
  }

  dynamic "operating_system" {
    for_each = (each.value.ct_type == "template") ? ["enabled"] : []
    content {
      template_file_id = "${each.value.src_file.datastore_id}:vztmpl/${each.value.src_file.file_name}"
      type             = each.value.ct_os
    }
  }

  cpu {
    architecture = each.value.ct_cpu.arch
    cores        = each.value.ct_cpu.cores
    units        = each.value.ct_cpu.units
  }

  memory {
    dedicated = each.value.ct_mem.dedicated
    swap      = each.value.ct_mem.swap
  }

  disk {
    datastore_id = each.value.ct_disk.datastore_id
    size         = each.value.ct_disk.size
  }

  console {
    enabled   = each.value.ct_console.enabled
    type      = each.value.ct_console.type
    tty_count = each.value.ct_console.tty_count
  }

  features {
    nesting = each.value.ct_features.nesting
    fuse    = each.value.ct_features.fuse
    keyctl  = each.value.ct_features.keyctl
    mount   = each.value.ct_features.mount
  }

  dynamic "network_interface" {
    for_each = each.value.ct_net_ifaces
    content {
      name    = network_interface.value.name != null ? network_interface.value.name : network_interface.key
      bridge  = network_interface.value.bridge
      enabled = network_interface.value.enabled
      mtu     = network_interface.value.mtu
      vlan_id = network_interface.value.vlan_id
    }
  }

  initialization {
    hostname = each.value.ct_name

    dynamic "ip_config" {
      for_each = each.value.ct_net_ifaces
      content {
        ipv4 {
          address = ip_config.value.ipv4_addr
          gateway = ip_config.value.ipv4_gw
        }
      }
    }

    user_account {
      # Use provided password or the generated one for this specific key
      password = each.value.ct_user.password != null ? each.value.ct_user.password : (
        contains(keys(random_password.ct_root_pw), each.key) ? random_password.ct_root_pw[each.key].result : null
      )
      keys = var.ssh_config.public_keys
    }
  }
}

resource "time_sleep" "wait_for_ct" {
  for_each        = { for k, v in var.containers : k => v if length(v.ct_bootstrap) > 0 }
  create_duration = "20s"

  triggers = {
    id = proxmox_virtual_environment_container.pve_ct[each.key].id
  }
}

resource "terraform_data" "copy_files" {
  for_each = { for task in local.copy_tasks : task.id => task }

  connection {
    type        = "ssh"
    host        = replace(proxmox_virtual_environment_container.pve_ct[each.value.ct_key].initialization[0].ip_config[0].ipv4[0].address, "/24", "")
    user        = "root"
    private_key = file(var.ssh_config.privkey_path)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${dirname(each.value.dst)}",
    ]
  }

  provisioner "file" {
    source      = each.value.src
    destination = each.value.dst
  }

  depends_on = [time_sleep.wait_for_ct]
}

resource "terraform_data" "bootstrap_ct" {
  for_each = { for task in local.bootstrap_tasks : task.id => task }

  connection {
    type        = "ssh"
    host        = replace(proxmox_virtual_environment_container.pve_ct[each.value.ct_key].initialization[0].ip_config[0].ipv4[0].address, "/24", "")
    user        = "root"
    private_key = file(var.ssh_config.privkey_path)
  }

  provisioner "file" {
    source      = each.value.file
    destination = "/etc/nixos/${basename(each.value.file)}"
  }

  provisioner "remote-exec" {
    inline = [
      "while systemctl is-active --quiet nixos-rebuild-switch-to-configuration.service; do sleep 5; done",
      "systemctl stop nixos-rebuild-switch-to-configuration.service || true",
      "systemctl reset-failed nixos-rebuild-switch-to-configuration.service || true",
      "nix-channel --update",
      "nixos-rebuild switch --upgrade"
    ]
  }

  depends_on = [time_sleep.wait_for_ct, terraform_data.copy_files]
}
