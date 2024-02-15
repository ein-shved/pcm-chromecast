{ nixosTest, lib }:
nixosTest
  {
    name = "chromecast-pcm";

    nodes.machine = {
      imports = [ ./service.nix ];
      services.chromecast-pcm = {
        enable = true;
        device = "hw:1";
      };
    };

    testScript = {nodes, ...}: ''
      machine.wait_for_unit("chromecast-pcm.service")
      machine.wait_for_open_port(5000)
    '';
  }
