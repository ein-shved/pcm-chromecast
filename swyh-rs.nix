{pkgs, ...}: let
  caster = pkgs.stdenv.mkDerivation {
    name = "caster";
    propagatedBuildInputs = [
      (pkgs.python3.withPackages (pythonPackages:
        with pythonPackages; [
          zeroconf
          pychromecast
        ]))
    ];
    dontUnpack = true;
    installPhase = "install -Dm755 ${./caster.py} $out/bin/caster";
  };
in {
  environment.systemPackages = with pkgs; [swyh-rs-cli ffmpeg];
  services.swyh.pcm-cast = {
    enable = true;
    sound_source = 1;
    streaming_format = "Wav";
  };
  systemd.services = {
    "caster" = {
      after = ["swyh-pcm-cast.service"];
      wantedBy = ["swyh-pcm-cast.service"];
      serviceConfig = {
        ExecStart = "${caster}/bin/caster";
      };
    };
  };
  networking.firewall = {
    allowedUDPPorts = [ 5353 ];
  };
}
