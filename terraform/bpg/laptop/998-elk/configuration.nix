{ config, lib, pkgs, meta, ... }:
let
  elk_version = "9.4.0";
  ip_address = "192.168.0.198";
  sops-nix = builtins.fetchTarball {
    url = "https://github.com/Mic92/sops-nix/archive/master.tar.gz";
  };
in
{
  imports = [
    ./standard.nix
    "${sops-nix}/modules/sops"
  ];

  networking.firewall.allowedTCPPorts = [ 5044 5601 9200 ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = ./age_keys.txt;
    secrets.elastic_password = {};
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/elasticsearch 0750 1000 1000 -"
  ];

  systemd.services.init-elk-network = {
    description = "Create the internal network for ELK";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network inspect elk-net || \
      ${pkgs.docker}/bin/docker network create --driver bridge elk-net
    '';
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      elasticsearch = {
        image = "docker.elastic.co/elasticsearch/elasticsearch:${elk_version}";
        ports = [ "9200:9200" ];
	volumes = [ "/var/lib/elasticsearch:/usr/share/elasticsearch/data" ];
        environment = {
          "discovery.type" = "single-node";
          "xpack.security.enabled" = "true";
          "ES_JAVA_OPTS" = "-Xms1g -Xmx1g";
        };
        environmentFiles = [ config.sops.secrets."elastic_password".path ];
	extraOptions = [ "--network=elk-net" "--name=elasticsearch" ];
      };

      logstash = {
        image = "docker.elastic.co/logstash/logstash:${elk_version}";
        ports = [ "192.168.0.198:5044:5044" ];
        dependsOn = [ "elasticsearch" ];
        volumes = [
          "${pkgs.writeText "logstash.conf" ''
            input { beats { port => 5044 } }
            output {
              elasticsearch {
                hosts => [ "http://elasticsearch:9200" ]
                user => "elastic"
                password => "''${ELASTIC_PASSWORD}"
              }
            }
          ''}:/usr/share/logstash/pipeline/logstash.conf:ro"
        ];
        environment = {
          "ES_JAVA_OPTS" = "-Xms1g -Xmx1g";
        };
        environmentFiles = [ config.sops.secrets."elastic_password".path ];
	extraOptions = [ "--network=elk-net" "--name=logstash" ];
      };

      kibana = {
        image = "docker.elastic.co/kibana/kibana:${elk_version}";
        ports = [ "192.168.0.198:5601:5601" ];
        environment = {
          "ELASTICSEARCH_HOSTS" = "http://elasticsearch:9200";
          "SERVER_HOST" = "0.0.0.0";
          "ELASTICSEARCH_USERNAME" = "kibana_system";
          "ES_JAVA_OPTS" = "-Xms2g -Xmx2g";
        };
        environmentFiles = [ config.sops.secrets."elastic_password".path ];
        dependsOn = [ "elasticsearch" ];
	extraOptions = [ "--network=elk-net" "--name=kibana" ];
      };
    };
  };
}
