{ pkgs, ... } :
{
  environment.systemPackages = with pkgs; [ swyh-rs-cli ffmpeg ];
  services.swyh.pcm-cast = {
    enable = true;
    sound_source = 1;
    streaming_format = "Wav";
  };
}
