{ config, lib, pkgs, meta, ... }:
let
in
{
  imports = [ ./standard.nix ];

  networking.firewall.allowedTCPPorts = [
    80 # default http port
  ];

  services.nginx = {
    enable = true;
    virtualHosts."ayanami.site" = {
      root = "/var/www/site";
      locations."/".index = "rei.jpg";
    };
  };

}
