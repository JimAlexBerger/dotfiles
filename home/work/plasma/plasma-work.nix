{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    catppuccin-kde
    catppuccin-cursors
    plasma-browser-integration
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
        theme = "catppuccin-frappe-blue-cursors";
        size = 24;
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
        alignment = "center";
        floating = false;
        height = 34;
        lengthMode = "fill";
        location = "bottom";
        screen = 0;
        widgets = [
          "org.kde.plasma.kickoff"
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.konsole.desktop"
              ];
            };
          }
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
