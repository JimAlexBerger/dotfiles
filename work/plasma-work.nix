{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    catppuccin-kde
    catppuccin-cursors
  ];

  programs.plasma = {
    enable = true;
    overrideConfig = true;
    #
    # Some high-level settings:
    #
    workspace = {
      clickItemTo = "select";
      lookAndFeel = "Catppuccin-Frappe-Blue";
      colorScheme = "CatppuccinFrappeBlue";

      cursor = {
        theme = "breeze_cursors";
        size = 32;
      };

      wallpaperPictureOfTheDay = {
        provider = "apod";
        updateOverMeteredConnection = true;
      };
    };

    fonts = {
      general = {
        family = "JetBrains Mono";
        pointSize = 12;
      };
    };

    panels = [
      # Windows-like panel at the bottom
      {
        screen = "all";
        location = "bottom";
        height = 44;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    #
    # Some mid-level settings:
    #
    shortcuts = {
      ksmserver = {
        "Lock Session" = [ "Screensaver" "Meta+L" ];
      };

      kwin = {
        "Expose" = "Meta+,";
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
      };
    };

    #
    # Some low-level settings:
    #
    configFile = {
      "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
      "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "SF";
      "kwinrc"."Desktops"."Number" = {
        value = 8;
        # Forces kde to not change this value (even through the settings app).
        immutable = true;
      };
    };
  };

  programs.konsole = {
    enable = true;
    defaultProfile = "catppuccin_frappe";
    profiles = {
      catppuccin_frappe = {
        font.name = "JetBrainsMono";
        colorScheme = "catppuccin-frappe";
      };
    };
  };

  home.file.".local/share/konsole/catppuccin-frappe.colorscheme".source = ./konsole-colorschemes/catppuccin-frappe.colorscheme;
}
