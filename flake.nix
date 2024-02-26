{
  inputs = {
    swyh-rs.url = github:ein-shved/swyh-rs/nix;
  };
  outputs = { self, nixpkgs, flake-utils, swyh-rs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pypackages = ps: with ps; [
          zeroconf
          pychromecast
          flask
          pyaudio
          ffmpeg-python
          uritools
          uuid
          pylint
        ];
      in
      {
        devShells = {
          default = pkgs.mkShell {
            packages = [
              (pkgs.python3.withPackages pypackages)
              pkgs.ffmpeg
              pkgs.pyright
            ];
          };
        };
        packages = {
          firmware = pkgs.callPackage ./firmware {
            inherit nixpkgs;
            configuration = {
              imports = [ ./service.nix ./swyh-rs.nix ] ++ swyh-rs.modules;
              services.chromecast-pcm = {
                enable = false;
                device = "hw:1";
              };
            };
          };
          chromecast-pcm = pkgs.callPackage ./default.nix {};
          test = pkgs.callPackage ./test.nix {};
        };
      });
}
