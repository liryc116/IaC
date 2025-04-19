resource "proxmox_vm_qemu" "k8s-controller" {
    desc = "First Terraform machine"
    # Gets the first node of the list
    target_node = local.servers[keys(local.servers)[0]].node

    count = 1
    agent = 1

    onboot = true
    full_clone = true

    vmid = count.index + 900
    name = format("k8s-controller-%02d", count.index + 1)

    clone = "k8s-template"
    cores = 4
    sockets = 1
    numa = true
    vcpus = 0
    cpu = "host"
    memory = 8192

    network {
        bridge = local.servers[keys(local.servers)[0]].bridge
        model = "virtio"
    }

    cloudinit_cdrom_storage = "local"
        scsihw   = "virtio-scsi-single"
    bootdisk = "scsi0"

    disks {
        scsi {
            scsi0 {
                disk {
                    storage = "local"
                    format = "qcow2"
                    size = 20
                }
            }
        }
    }

    os_type = "cloud-init"
    ciuser = "user"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCit9xqC+/EcC0D+x4Irg/AgnTx9rJDbE4FdKK2Z2vE0nSPzp1MbAtijVi5ndvr/JPlY3jUHeGEZBJHmADXeOvdJl1nvkqry/69phfr4nDYacvH0v66nDTRipqmCmebaYOkfXYG55oy40+6C6DwAGETTYq+PIaRcA/mSf6V9UxKBfnLVqdml7LFYEo1SbihAIFd0EZkwq1wevXdVmrDwF7VLiCin/5Axa6LUOe4l1SAYBpsV8pCY3PQ/KxpgCyJuYj2szhOl0shTPiV48f194xGtYrpx1uGhOHRDx6Rm/5LKY/5DUvKbHCa/ZAdUSoMTnd1TshAPJe1sYKSAAI1xPVmffOgF/Jh98QEuAuFmHfZXVgPdvApJ9r9Ea7gEyN6Xe37emkW1Dond4ARdNdaslVu0iwV6bQnDOGcEdAl3x3seRVRAiPAKp2tAEtVEqu7uFwX6v2mmpE5/uw8rfsl/wNgttjuYa/kJURNkto3bN02XNfzOnXXZ3bRtbNjHEyJQuM=
    EOF

    provisioner "remote-exec" {
      inline = [format("sudo hostnamectl set-hostnae k8s-controller-%02d", count.index + 1)]
    }
}
