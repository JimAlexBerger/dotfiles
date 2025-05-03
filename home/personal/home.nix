{ config, pkgs, ... }:

{
  home.username = "jimalexberger";
  home.homeDirectory = "/home/jimalexberger";

  home.stateVersion = "23.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    hello
    cowsay    
    alacritty
    neofetch
    tldr
    manix
    fzf
    vscode
    firefox
    jetbrains.rider
    (with dotnetCorePackages; combinePackages [
      sdk_8_0
      sdk_9_0
    ])
    s3cmd
    tmux
    scummvm
    qbittorrent
    unrar
    unzip
    remmina
    github-cli
    pavucontrol
    wofi
    kdePackages.dolphin

    nh
  ];

  programs.kitty.enable = true;
  programs.btop.enable = true;
  programs.fastfetch.enable = true;
  programs.hyprlock.enable = true;

  services.hyprpaper.enable = true;
  stylix = {
    autoEnable = true;
    targets.hyprpaper.enable = true;
  };


  home.sessionVariables = {
    NH_FLAKE = "/home/jimalexberger/.dotfiles";
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-19.1.9"
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      yzhang.markdown-all-in-one
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
