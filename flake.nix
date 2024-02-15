{
  outputs = { self, nixpkgs, flake-utils }:
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
          chromecast-pcm = pkgs.callPackage ./default.nix {};
          test = pkgs.callPackage ./test.nix {};
        };
      });
}
