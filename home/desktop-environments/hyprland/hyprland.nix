{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprpaper
    hyprlock
  ];

  # Hyprpaper
  services.hyprpaper.enable = true;
  stylix.targets.hyprpaper.enable = true;

  # Hyprlock
  programs.hyprlock.enable = true;

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # Let mother OS handle installation
    portalPackage = null;
    settings = {
      monitor = [
        "eDP-1,preferred,0x0,1.25"
        "DP-4,preferred,-2560x0,auto"
        "DP-3,preferred,auto-left,0.75"
        "HDMI-A-1,1920x1080@50,auto-right,auto, mirror, eDP-1"
        " , preferred, auto, 1, mirror, eDP-1"
      ];
      exec-once = [
        "waybar & hyprpaper"
      ];
      general = {
        gaps_in = 5;
        gaps_out = 20;

        border_size = 2;

        # Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false;

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;

        layout = "dwindle";
      };
      decoration = {
        rounding = 10;

        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
        };
      };
      animations = {
        enabled = true;

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      misc = {
        force_default_wallpaper = 1; # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true; # If true disables the random hyprland logo / anime girl background. :(
      };
      xwayland = {
        use_nearest_neighbor = false;
        force_zero_scaling = true;
      };
      input = {
        kb_layout = "no";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad = {
          natural_scroll = false;
        };
      };
      "$mainMod" = "SUPER";
      bind =
        [
          "$mainMod, Q, exec, konsole"
          "$mainMod, C, killactive"
          "$mainMod, R, exec, wofi --show drun"
          "$mainMod, L, exec, hyprlock"

          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
        ]
        ++ (
          # workspaces
          # binds $mainMod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList
            (i:
              let
                ws = if i == 0 then 10 else i;
              in
              [
                "$mainMod, ${toString i}, workspace, ${toString ws}"
                "$mainMod SHIFT, ${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            10)
        );
      bindm = [
        "$mainMod, mouse:272, movewindows"
        "$mainMod, mouse:273, resizewindow"
      ];
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];
      windowrulev2 = "suppressevent maximize, class:.*";
      debug = {
        disable_logs = false;
      };
    };
  };
}
