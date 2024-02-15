{ lib, pkgs, config, ... }:
let
  cfg = config.services.chromecast-pcm;
  appEnv = pkgs.python3.withPackages (p: with p; [ (callPackage ./default.nix {}) ]);
in {
  options.services.chromecast-pcm = with lib.types; {
    enable = lib.mkEnableOption "chromecast-pcm";
    device = lib.mkOption {
      type = str;
      description = "Name of PCM device";
      example = "hw:1";
    };

    # TODO more options
  };

  config = lib.mkIf cfg.enable {
    systemd.services.chromecast-pcm = {
      wantedBy = [ "multi-user.target" ];
      environment = with cfg; {
        FLASK_DEVICE = device;
      };
      serviceConfig = {
        ExecStart = "${appEnv}/bin/flask --app server run -h 0.0.0.0";
      };
    };
    networking.firewall = {
      allowedTCPPorts = [ 5000 ];
    };
  };
}
