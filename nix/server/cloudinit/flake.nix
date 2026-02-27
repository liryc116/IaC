{
  description = "A nixos cloudinit base image";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };
  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    inherit (pkgs) lib;
    baseModule = { lib, config, pkgs, ...}: {
      nixpkgs.hostPlatform = "x86_64-linux";
      imports = [
        "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
      ];
      networking = {
        hostName = "nixos-cloudinit";
      };
      nix.settings.experimental-features = ["nix-command" "flakes"];
      fileSystems."/" = {
        label = "nixos";
        fsType = "ext4";
        autoResize = true;
      };
      boot.loader.grub.device = "/dev/sda";

      services.openssh.enable = true;
      services.qemuGuest.enable = true;

      security.sudo.wheelNeedsPassword = false;
      users.users.trespass = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
      nix.settings.trusted-users = [ "trespass" ]; # a very imoprtant step

      networking = {
        dhcpcd.enable = false;
        interfaces.eth0.useDHCP = false;
      };
      systemd.network.enable = true;
      services.cloud-init = {
        enable = true;
        network.enable = true;
        config = ''
          system_info:
            distro: nixos
            network:
              renderers: [ 'networkd' ]
            default_user:
              name: trespass
          users:
              - default
          ssh_pwauth: false
          chpasswd:
            expire: false
          cloud_init_modules:
            - migrator
            - seed_random
            - growpart
            - resizefs
          cloud_config_modules:
            - disk_setup
            - mounts
            - set-passwords
            - ssh
          cloud_final_modules: []
          '';
      };
    };
    nixos = nixpkgs.lib.nixosSystem {
      modules = [baseModule];
    };
    make-disk-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix";
  in {
    inherit pkgs;
    image = make-disk-image {
      inherit pkgs lib;
      config = nixos.config;
      name = "nixos-cloudinit";
      format = "qcow2-compressed";
      copyChannel = true; # copy the host's channel
    };
  };
}
