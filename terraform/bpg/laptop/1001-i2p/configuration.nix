{ config, lib, pkgs, meta, ... }:
let
  ip_address = "192.168.0.201";
in
{
  imports = [
    ./standard.nix
  ];

  networking.firewall.allowedTCPPorts = [
    7070 # default web interface port
    4447 # default socks proxy port
    4444 # default http proxy port
	7656
  ];

  services.i2pd = {
    enable = true;
    address = ip_address;
    logLevel = "warn";
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
      ayanami = {
        enable = true;
        keys = "ayanami-keys.dat";
        inPort = 80;
        address = "192.168.0.199";
        port = 80;
      };
    };
  };

  services.filebeat.settings = {
    filebeat.inputs = [
      {
        type = "journald";
        id = "i2pd-journal"; # Unique ID for this input
        include_matches = [ "_SYSTEMD_UNIT=i2pd.service" ];
        tags = [ "i2p" "nixos" ];
      }
    ];
  };
}

