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

  services.filebeat.settings.filebeat.inputs =  [
    {
      type = "filestream";
      id = "nginx-logs";
      paths = [ "/var/log/nginx/error.log*" "/var/log/nginx/ayanami.access.log*"];
     }
  ];

  services.filebeat.modules = {
    nginx = {
      access = {
        enabled = true;
        var.paths = [ "/path/to/log/nginx/access.log*" ];
      };
      error = {
        enabled = true;
        var.paths = [ "/path/to/log/nginx/error.log*" ];
      };
    };
  };
}
