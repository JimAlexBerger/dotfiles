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
  stylix.targets.hyprlock.enable = true;
}
