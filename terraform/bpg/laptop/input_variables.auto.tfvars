pve_node = "laptop"
ct_type = "template"

src_file = {
    datastore_id = "local",
    file_name = "nixos-25.11-default_321936167_amd64.tar.xz"
}

ct_name = "i2p-node"
ct_id = 1001

ct_tags = [ "nixos", "i2p" ]

ct_os = "nixos"

ct_disk = {
    datastore_id = "local",
    size = 8
}

ct_net_ifaces = {
    net0 = {
        name = "veth0",
        ipv4_addr = "192.168.0.51/24",
        ipv4_gw = "192.168.0.1"
    }
}

ct_init = {
    user = {
        keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCit9xqC+/EcC0D+x4Irg/AgnTx9rJDbE4FdKK2Z2vE0nSPzp1MbAtijVi5ndvr/JPlY3jUHeGEZBJHmADXeOvdJl1nvkqry/69phfr4nDYacvH0v66nDTRipqmCmebaYOkfXYG55oy40+6C6DwAGETTYq+PIaRcA/mSf6V9UxKBfnLVqdml7LFYEo1SbihAIFd0EZkwq1wevXdVmrDwF7VLiCin/5Axa6LUOe4l1SAYBpsV8pCY3PQ/KxpgCyJuYj2szhOl0shTPiV48f194xGtYrpx1uGhOHRDx6Rm/5LKY/5DUvKbHCa/ZAdUSoMTnd1TshAPJe1sYKSAAI1xPVmffOgF/Jh98QEuAuFmHfZXVgPdvApJ9r9Ea7gEyN6Xe37emkW1Dond4ARdNdaslVu0iwV6bQnDOGcEdAl3x3seRVRAiPAKp2tAEtVEqu7uFwX6v2mmpE5/uw8rfsl/wNgttjuYa/kJURNkto3bN02XNfzOnXXZ3bRtbNjHEyJQuM="
        ]
    }
}

ct_ssh_privkey = "~/.ssh/id_rsa"

ct_bootstrap = [
    "standard.nix",
    "i2p/configuration.nix"
]

ct_features = {
    nesting = true
}
