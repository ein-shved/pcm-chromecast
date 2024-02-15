{ python3Packages
}:
python3Packages.buildPythonPackage {
  name = "chromecast-pcm";
  propagatedBuildInputs = with python3Packages; [
    flask
    pychromecast
    ffmpeg-python
  ];
  src = ./.;
}
