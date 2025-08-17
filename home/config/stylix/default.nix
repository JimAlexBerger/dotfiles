{ pkgs, ... }:
{
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";

    image = pkgs.fetchurl {
      url = "https://ms01.nasjonalmuseet.no/api/objects/download?filename=NG.M.00305+(2).tif&size=full";
      sha256 = "sha256-P/ib2OK71RffqlOSr5Gnz4dHGh2GMdppUrplZ8OVM7A=";
    };
    #image = ../desktop-environments/wallpaper/20250615_0055.jpg;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 15;
    };

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };

    fonts.sizes = {
      applications = 10;
      terminal = 10;
      desktop = 10;
      popups = 10;
    };

    opacity = {
      applications = 1.0;
      terminal = 0.9;
      desktop = 1.0;
      popups = 1.0;
    };

    polarity = "dark";

    targets.firefox.profileNames = [ "default" ];
  };
}
