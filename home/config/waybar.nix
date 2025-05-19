{ config, pkgs, ... }:
let
  oddjob-health = serverUrl: numNodes: icon:
    pkgs.writeShellApplication {
      name = "waybar-oddjob";
      runtimeInputs = with pkgs; [ pbm jq curl ];
      text = ''
        pbm=$(pbm ${serverUrl}:9121 cluster show)
        num=$(echo "$pbm" | tail -n 1 | cut -d ' ' -f2)
        tooltip="$pbm"
        if [[ "$num" -eq ${numNodes} ]]; then
          status=ok
        else
          status=error
        fi

        health=$(curl -s "${serverUrl}:1953/health" | jq -r '.statusMessage' )

        if [[ "$health" != "null" ]]; then
          status=error
          tooltip="$tooltip \n$health"
        fi

        json=$(jq --unbuffered --compact-output -n \
          --arg text "${icon}" \
          --arg tooltip "$tooltip" \
          --arg class "$status" \
          '{"text":$text,"tooltip":$tooltip,"class":$class}')

        echo "$json"
      '';
    };
  waybar-oddjob-prod = oddjob-health "maodadist03" "15" "󰰙";
  waybar-oddjob-stage = oddjob-health "maodadiststg03" "10" "󰰢";
  waybar-oddjob-test = oddjob-health "maodatest01" "10" "󰰥";
in
{
  home.packages = with pkgs; [
    pulsemixer
    waybar-oddjob-prod
  ];

  programs.waybar.enable = true;

  programs.waybar.settings = {
    mainBar = {
      modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
      modules-center = [ "clock" ];
      modules-right = [ "tray" "custom/oddjob-test" "custom/oddjob-stage" "custom/oddjob-prod" "network" "pulseaudio" "battery" "custom/shutdown" ];

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

      "custom/oddjob-test" = {
        exec = "${waybar-oddjob-test}/bin/waybar-oddjob";
        # exec-if = "${(pkgs.writeShellScript "waybar-oddjob-if-prod" ''${pkgs.curl}/bin/curl -s -o /dev/null "maodadist03"'') }/bin/waybar-oddjob-if-prod";
        return-type = "json";
        interval = 120;
      };

      "custom/oddjob-stage" = {
        exec = "${waybar-oddjob-stage}/bin/waybar-oddjob";
        # exec-if = "${(pkgs.writeShellScript "waybar-oddjob-if-prod" ''${pkgs.curl}/bin/curl -s -o /dev/null "maodadist03"'') }/bin/waybar-oddjob-if-prod";
        return-type = "json";
        interval = 120;
      };

      "custom/oddjob-prod" = {
        exec = "${waybar-oddjob-prod}/bin/waybar-oddjob";
        # exec-if = "${(pkgs.writeShellScript "waybar-oddjob-if-prod" ''${pkgs.curl}/bin/curl -s -o /dev/null "maodadist03"'') }/bin/waybar-oddjob-if-prod";
        return-type = "json";
        interval = 60;
      };

      "network" = {
        format-wifi = "";
        format-ethernet = "";
        format-disconnected = "";
        tooltip-format-wifi = "{essid}: {ipaddr}/{cidr} ({signalStrength}%)";
        tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
        tooltip-format-disconnected = "Disconnected";
        max-length = 100;
        on-click = "kitty -e 'nmtui'";
      };

      "pulseaudio" = {
        format = "{icon}";
        format-muted = "";
        format-icons = {
          default = [ "" "" ];
        };
        tooltip = true;
        tooltip-format = "{desc}: {volume}%";
        on-click = "kitty -e 'pulsemixer'";
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

      "custom/shutdown" = {
        format = "";
        on-click = "poweroff";
        tooltip = false;
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
    #tray,
    #custom-oddjob-test,
    #custom-oddjob-stage,
    #custom-oddjob-prod,
    #network,
    #pulseaudio,
    #battery,
    #custom-shutdown {
        padding: 0 10px;
    }

    #custom-oddjob-test.error {
        color: @base08;
    }

    #custom-oddjob-stage.error {
        color: @base08;
    }

    #custom-oddjob-prod.error {
        color: @base08;
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

    tooltip {
      background-color: @base00;
    }
  '';

  stylix.targets.waybar = {
    addCss = false;
    font = "monospace";
  };
}
