# Windows Server
# ---
# Packer Template to create a Windows Server on Proxmox

# Variable Definitions
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "proxmox_node" {
    type = string
}

# plugin for proxmox
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Resource Definiation for the VM Template
source "proxmox-iso" "windows-dfir" {

    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"

    insecure_skip_tls_verify = true
    # VM General Settings
    node = "${var.proxmox_node}"
    vm_id = "404"
    vm_name = "windows-dfir"
    template_description = "Windows Pro Image for DFIR"

    communicator = "winrm"
    winrm_timeout = "30m"
    winrm_username = "Admin"
    winrm_password = "AdminPass"

    # VM OS Settings
    boot_iso {
      type = "scsi"
      iso_file = "NFS-ISO:iso/Windows10-dfir.iso"
      unmount = true
      iso_checksum = "none"

      iso_storage_pool = "disk3"
    }

    additional_iso_files {
      type = "scsi"
      iso_storage_pool = "disk3"
      unmount = true
      iso_checksum = "none"
      cd_content = {}
      cd_files = [
        "${path.root}/files/install_tools.ps1",
        "${path.root}/files/install_virtio.ps1"
      ]
    }

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "200G"
        format = "raw"
        storage_pool = "extra-disk"
        type = "virtio"
    }

    # VM CPU Settings
    cores = "8"

    # VM Memory Settings
    memory = "8192"

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr1"
        firewall = "false"
    }

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local"

    # PACKER Boot Commands
    boot = "dc"
    boot_wait = "4s"

    boot_command = [
      "<spacebar>"
      #   "<esc><wait>",
      #   "<esc><wait>",
      #   "<enter><wait>",
      #   "<f8><wait>",
      #   "<wait10>",
      #   "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
      #   "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
      #   "wpeinit<enter>"
    ]

    http_directory = "./http"
    ssh_username = "Administrator"
}

build {
  sources = ["source.proxmox-iso.windows-dfir"]

  provisioner "powershell" {
    inline = [
      "Set-ExecutionPolicy Unrestricted -Force",
      ".\\install_virtio.ps1",
      ".\\install_tools.ps1"
    ]
  }
}
