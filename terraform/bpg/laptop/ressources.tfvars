pve_node = "server"

ssh_config = {
    privkey_path = "~/.ssh/id_rsa"
    public_keys = [
        "ssh-rsa ... computer"
    ]
}

containers = {
    "i2p" = {
        ct_name = "i2p-node"
        ct_id = 1001

        ct_tags = [ "nixos", "i2p" ]
        ct_os = "nixos"

        src_file = {
            datastore_id = "local",
            file_name = "nixos-25.11-default_321936167_amd64.tar.xz"
        }

        ct_net_ifaces = {
            net0 = {
                name = "veth0",
                ipv4_addr = "10.0.0.101/24",
                ipv4_gw = "10.0.0.1"
            }
        }

        ct_user = {
            keys = [ "ssh-rsa ... computer" ]
        }

        ct_ssh_privkey = "~/.ssh/id_rsa"

        ct_bootstrap = [
            "standard.nix", "1001-i2p/configuration.nix"
        ]
    }

    "web" = {
        ct_name = "website"
        ct_id = 999

        ct_tags = [ "nixos", "nginx" ]
        ct_os = "nixos"

        src_file = {
            datastore_id = "local",
            file_name = "nixos-25.11-default_321936167_amd64.tar.xz"
        }

        ct_net_ifaces = {
            net0 = {
                name = "veth0",
                ipv4_addr = "10.0.0.99/24",
                ipv4_gw = "10.0.0.1"
            }
        }
        ct_user = {
            keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCit9xqC+/EcC0D+x4Irg/AgnTx9rJDbE4FdKK2Z2vE0nSPzp1MbAtijVi5ndvr/JPlY3jUHeGEZBJHmADXeOvdJl1nvkqry/69phfr4nDYacvH0v66nDTRipqmCmebaYOkfXYG55oy40+6C6DwAGETTYq+PIaRcA/mSf6V9UxKBfnLVqdml7LFYEo1SbihAIFd0EZkwq1wevXdVmrDwF7VLiCin/5Axa6LUOe4l1SAYBpsV8pCY3PQ/KxpgCyJuYj2szhOl0shTPiV48f194xGtYrpx1uGhOHRDx6Rm/5LKY/5DUvKbHCa/ZAdUSoMTnd1TshAPJe1sYKSAAI1xPVmffOgF/Jh98QEuAuFmHfZXVgPdvApJ9r9Ea7gEyN6Xe37emkW1Dond4ARdNdaslVu0iwV6bQnDOGcEdAl3x3seRVRAiPAKp2tAEtVEqu7uFwX6v2mmpE5/uw8rfsl/wNgttjuYa/kJURNkto3bN02XNfzOnXXZ3bRtbNjHEyJQuM=" ]
        }

        ct_ssh_privkey = "~/.ssh/id_rsa"

        ct_bootstrap = [
            "standard.nix", "999-nginx/configuration.nix"
        ]
        ct_copy_files = [
          {
            src = "999-nginx/rei.jpg",
            dst = "/var/www/site/rei.jpg"
          }
        ]
    }
}
