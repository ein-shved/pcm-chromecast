{
  hardware.deviceTree = {
    enable = true;
    filter = "sun50i-h616-orangepi-zero2.dtb";
    overlays = [
      {
        name = "sun50i-h616-orangepi-zero2.dtb";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "xunlong,orangepi-zero2", "allwinner,sun50i-h616";
          };

          &ehci0 {
            status = "okay";
          };

          &ehci1 {
            status = "okay";
          };

          &ehci2 {
            status = "okay";
          };

          &ehci3 {
            status = "okay";
          };

          &ohci0 {
            status = "okay";
          };

          &ohci1 {
            status = "okay";
          };

          &ohci2 {
            status = "okay";
          };

          &ohci3 {
            status = "okay";
          };
        '';
      }
    ];
  };
}
