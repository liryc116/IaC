{ config, lib, pkgs, meta, ... }:
let
  ip_address = "your router IP";
in
{
  imports = [ ./standard.nix ];

  networking.firewall.allowedTCPPorts = [
    7070 # default web interface port
    4447 # default socks proxy port
    4444 # default http proxy port
	7656
  ];

  services.i2pd = {
    enable = true;
    address = ip_address;
    proto = {
      http = {
        enable = true;
        address = ip_address;
      };
      socksProxy = {
        enable = true;
        address = ip_address;
      };
      httpProxy = {
        enable = true;
        address = ip_address;
      };
      sam = {
        enable = true;
        address = ip_address;
      };
    };
    inTunnels = {
      website = {
        enable = true;
        keys = "website-keys.dat";
        inPort = 80;
        address = "#web server IP";
        port = 80;
      };
    };
  };

}

