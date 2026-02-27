{ config, lib, pkgs, meta, ... }:
let
    vars = import ./vars.nix;
in
{
  imports = [ ./configuration.nix ];

  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${meta.hostname}";
  };

  services.nfs.server = {
    enable = true;
    extraNfsdConfig = '''';
  };

  networking.hostName = meta.hostname; # Define your hostname.

  services.k3s = {
    enable = true;
    role = "server";
    #tokenFile = "/var/lib/ran"cher/k3s/server/token";
    token="0B0wnUTwHFL24NQy";
    extraFlags = toString ([
	    "--write-kubeconfig-mode \"0644\""
	    "--cluster-init"
	    "--disable servicelb"
	    "--disable traefik"
	    "--disable local-storage"
    ] ++ (if meta.hostname == "k3s-node-01" then [] else [
	      "--server https://k3s-node-01:6443"
    ]));
    clusterInit = (meta.hostname == "k3s-node-01");
  };
}
