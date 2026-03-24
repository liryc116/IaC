{ config, lib, pkgs, meta, ... }:
let
in
{
  imports = [ ./standard.nix ];

  services.i2pd = {
    enable = true;
    address = "0.0.0.0"; # you may want to set this to 0.0.0.0 if you are planning to use an ssh tunnel
    proto = {
      http.enable = true;
      socksProxy.enable = true;
      httpProxy.enable = true;
    };
  };

}
