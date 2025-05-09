{ config, pkgs, ... }:
{
  programs.waybar.enable = true;

  programs.waybar.settings = {
    mainBar = {
      modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
      modules-center = [ "clock" ];
      modules-right = [ "tray" "network" "battery" ];

      layer = "top";
      position = "top";
      height = 26;

      "clock" = {
        interval = 1;
        format = "{:%H:%M:%S}";
      };

      "tray" = {
        icon-size = 15;
        spacing = 10;
      };

      "network" = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ifname} ";
        format-disconnected = "";
        max-length = 100;
        on-click = "kitty -e 'nmtui'";
      };

      "battery" = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon}";
        format-icons = [ "" "" "" "" "" ];
        tooltip = true;
        tooltip-format = "{capacity}% : {timeTo}";
      };
    };
  };

  programs.waybar.style = ''
    * {
        border: none;
        color: @base07;
        border-radius: 20px;
    }
    window#waybar {
        background: rgba(0, 0, 0, 0);
    }
    /*-----module groups----*/
    .modules-right {
        background-color: @base00;
        margin: 10px 20px 0 0;
        padding: 5px;
    }
    .modules-center {
        background-color: @base00;
        margin: 10px 0 0 0;
        padding: 5px;
    }
    .modules-left {
        background-color: @base00;
        margin: 10px 0 0 20px;
        padding: 5px;
    }
    /*-----modules indv----*/
    #workspaces button {
        padding: 1px 5px;
        background-color: transparent;
    }
    #workspaces button:hover {
        box-shadow: inherit;
        background-color: @base0D;
    }

    #workspaces button.focused {
        background-color: @base02;
    }

    #clock,
    #battery,
    #cpu,
    #memory,
    #temperature,
    #network,
    #pulseaudio,
    #custom-media,
    #tray,
    #mode,
    #custom-power,
    #custom-menu,
    #idle_inhibitor {
        padding: 0 10px;
    }

    #battery.charging {
        color: @base0B;
    }
    #battery.warning:not(.charging) {
        color: @base0A;
    }
    #battery.critical:not(.charging) {
        color: @base08;
    }
  '';

  stylix.targets.waybar = {
    addCss = false;
    font = "monospace";
  };
}
