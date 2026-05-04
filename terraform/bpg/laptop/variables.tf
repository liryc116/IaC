variable "pve_node" {
  type        = string
  description = "PVE Node name on which the VM will be created on."

  validation {
    condition     = can(regex("[A-Za-z0-9.-]{1,63}", var.pve_node))
    error_message = "This variable is constrained by the node name requirements set forth by ProxmoxVE."
  }
}

variable "ssh_config" {
  type = object({
    privkey_path = string
    public_keys = list(string)
  })
}

variable "containers" {
  type        = map(object({
    ct_name = string
    ct_id   = optional(number)
    ct_unprivileged = optional(bool, true)
    ct_protection = optional(bool, false)
    ct_pool       = optional(string)

    ct_tags = optional(list(string), [])
    ct_start = optional(object({
      on_deploy  = optional(bool, true)
      on_boot    = optional(bool, true)
      order      = optional(number, 0)
      up_delay   = optional(number, 0)
      down_delay = optional(number, 0)
    }), {})
    ct_os = optional(string, "unmanaged")

    ct_type     = optional(string, "template")
    ct_template = optional(bool, false)

    src_clone = optional(object({
      datastore_id = string
      node_name    = optional(string)
      tpl_id       = number
    }))

    src_file = optional(object({
      datastore_id = optional(string, "local")
      file_name    = string
    }))

    ct_cpu = optional(object({
      arch  = optional(string)
      cores = optional(number, 2)
      units = optional(number)
    }), {})

    ct_mem = optional(object({
      dedicated = optional(number, 2048)
      swap      = optional(number)
    }), {})

    ct_console = optional(object({
      enabled   = optional(bool, true)
      type      = optional(string, "tty")
      tty_count = optional(number, 2)
    }), {})

    ct_features = optional(object({
      nesting = optional(bool, true)
      fuse    = optional(bool)
      keyctl  = optional(bool)
      mount   = optional(list(string))
    }), {})

    ct_disk = optional(object({
      datastore_id = optional(string, "local")
      size         = optional(number, 8)
    }), {datastore_id = "local", size = 8})

    ct_net_ifaces = optional(map(object({
      name       = optional(string)
      bridge     = optional(string, "vmbr0")
      enabled    = optional(bool, true)
      firewall   = optional(bool, true)
      model      = optional(string, "virtio")
      mtu        = optional(number, 1500)
      vlan_id    = optional(number)
      ipv4_addr  = optional(string, "dhcp") # dhcp blocks ssh
      ipv4_gw    = optional(string)
    })), {})

    ct_user = optional(object({
        password = optional(string)
        keys     = optional(list(string))
    }), {})

    ct_ssh_privkey = optional(string)
    ct_bootstrap = optional(list(string), [])
    ct_copy_files = optional(list(object({
      src = string
      dst = string
    })), [])
  }))

  default = {
    "default-ct" = {
      ct_name = "terraform-container"

      ct_start = {
        on_deploy  = true
        on_boot    = true
        order      = 0
        up_delay   = 0
        down_delay = 0
      }
      src_file = {
          datastore_id = "local",
          file_name = "nixos-25.11-default_321936167_amd64.tar.xz"
      }
    }
  }

  description = "Map of all the containers to create"

  validation {
    condition     = alltrue([for c in var.containers : contains(["clone", "template"], c.ct_type)])
    error_message = "Valid values for var: ct_type are (clone, template)."
  }

  validation {
    condition     = alltrue([for c in var.containers : can(regex("[A-Za-z0-9_-]{0,63}", c.ct_pool)) || c.ct_pool == null])
    error_message = "This variable is constrained by the pool name requirements set forth by ProxmoxVE."
  }

  validation {
    condition     = alltrue([for c in var.containers : contains(["alpine", "archlinux", "centos", "debian", "devuan", "fedora", "gentoo", "nixos", "opensuse", "ubuntu", "unmanaged"], c.ct_os)])
    error_message = "Valid values for var: ct_os are (alpine, archlinux, centos, debian, devuan, fedora, gentoo, nixos, opensuse, ubuntu, unmanaged)."
  }

  validation {
    condition = alltrue([
      for c in var.containers : alltrue([
        for k, v in c.ct_net_ifaces : can(regex("net\\d+", k))
      ])
    ])
    error_message = "The IDs (keys) of the network interfaces must respect the following convention: net[id]."
  }
}
