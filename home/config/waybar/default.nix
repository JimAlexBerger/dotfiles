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
          status=OK
        else
          status=FAIL
        fi

        health=$(curl -s "${serverUrl}:1953/health" | jq -r '.statusMessage' )
        healthstatus=$(curl -s "${serverUrl}:1953/health" | jq -r '.status' )

        if [[ "$health" != "null" ]]; then
          status=$healthstatus
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
  pomodoro-cli = pkgs.callPackage ../../../modules/applications/pomodoro-cli.nix { };
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
      modules-center = [ "custom/clock" ];
      modules-right = [ "tray" "custom/oddjob-test" "custom/oddjob-stage" "custom/oddjob-prod" "custom/pomodoro" "network" "pulseaudio" "battery" "custom/shutdown" ];

      layer = "top";
      position = "top";
      height = 26;

      "custom/clock" = {
        exec = "${pkgs.uutils-coreutils}/bin/uutils-date +%H:%M:%S";
        interval = 1;

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

      "custom/pomodoro" = {
        exec = "${pomodoro-cli}/bin/pom left";
        interval = 10;
        on-click = "${pomodoro-cli}/bin/pom start";
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
    
    #workspaces button.active {
        background-color: @base02;
    }
    
    #workspaces button:hover {
        box-shadow: inherit;
        background-color: @base0D;
    }

    #custom-clock,
    #tray,
    #custom-oddjob-test,
    #custom-oddjob-stage,
    #custom-oddjob-prod,
    #custom-pomodoro,
    #network,
    #pulseaudio,
    #battery,
    #custom-shutdown {
        padding: 0 10px;
    }

    #custom-oddjob-test.FAIL,
    #custom-oddjob-stage.FAIL,
    #custom-oddjob-prod.FAIL {
        color: @base08;
    }

    #custom-oddjob-test.WARNING,
    #custom-oddjob-stage.WARNING,
    #custom-oddjob-prod.WARNING {
        color: @base0A;
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

    #custom-pomodoro {
        background-color: @base02;
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
