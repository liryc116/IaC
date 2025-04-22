{ config, lib, pkgs, meta, ... }:
let
    vars = import ./vars.nix;
in
{
  imports = [./hardware-configuration.nix];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  services.qemuGuest.enable = true;
  security.sudo.wheelNeedsPassword = false;
  users.users."${vars.username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ vars.public_key ];
  };

  nix.settings.trusted-users = [ "trespass" ];
  networking = {
    defaultGateway = { address = vars.gateway; interface = "eth0"; };
    dhcpcd.enable = false;
    interfaces.eth0.useDHCP = false;
  };

  systemd.network.enable = true;
  time.timeZone = vars.time_zone;
  environment.systemPackages = with pkgs; [vim wget];
  networking.firewall.enable = false;
  system.stateVersion = "24.05";

  services.cloud-init = {
    enable = true;
    network.enable = true;
    config = ''
          system_info:
            distro: nixos
            network:
              renderers: [ 'networkd' ]
            default_user:
              name: ops
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
}
