{
  pkgsCross,
  lib,
  nixpkgs,
  compressImage ? false,
  stateVersion ? "23.11",
  configuration,
}: let
  system = "aarch64-linux";
  #Build manipulation
  pkgs = pkgsCross.aarch64-multiplatform;
  bootConfig = let
    bootloaderPackage = pkgs.ubootOrangePiZero2;
    bootloaderSubpath = "/u-boot-sunxi-with-spl.bin";
    ## Disable ZFS support to prevent problems with fresh kernels.
    filesystems = pkgs.lib.mkForce [
      "btrfs"
      "reiserfs"
      "vfat"
      "f2fs"
      "xfs"
      "ntfs"
      "cifs"
      /*
      "zfs"
      */
      "ext4"
      "vfat"
    ];
  in {
    system.stateVersion = stateVersion;
    #boot.kernelPackages =
    #  if useUnstableKernel
    #  then pkgsCross.linuxPackagesFor kernel
    #  else pkgsCross.linuxPackages_latest;
    boot.supportedFilesystems = filesystems;
    boot.initrd.supportedFilesystems = filesystems;
    boot.kernelPackages = pkgs.linuxPackages_6_7;
    sdImage = {
      postBuildCommands = ''
        # Emplace bootloader to specific place in firmware file
        dd if=${bootloaderPackage}${bootloaderSubpath} of=$img    \
          bs=8 seek=1024                                          \
          conv=notrunc # prevent truncation of image
      '';
      inherit compressImage;
    };
  };
  nixosSystem = nixpkgs.lib.nixosSystem rec {
    inherit system;
    modules = [
      # Default aarch64 SOC System
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      # Minimal configuration
      "${nixpkgs}/nixos/modules/profiles/minimal.nix"
      bootConfig
      ./configuration.nix
      configuration
    ];
  };
in
  nixosSystem.config.system.build.sdImage
