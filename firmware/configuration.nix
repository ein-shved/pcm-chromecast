{pkgs, ...}: {
  users.users.chromecast = {
    initialPassword = "chromecast";
    isNormalUser = true;
    extraGroups = ["wheel"];
  };
  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [alsa-utils];
}
