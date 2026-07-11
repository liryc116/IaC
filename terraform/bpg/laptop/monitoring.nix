{ config, modulesPath, pkgs, lib, ... }:
let
in
{
  services.filebeat = {
    enable = true;
    package = pkgs.filebeat8;
    settings = {
	output.elasticsearch = {
	  hosts = [ "192.168.0.198:9200" ];
	  username = "filebeat_writer";
	  password = { _secret = "/etc/nixos/elastic_pw.secret"; };
	};
    };
  };
}

