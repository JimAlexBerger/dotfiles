{ config, pkgs, ... }:

{
  home.username = "n651227";
  home.homeDirectory = "/home/n651227";

  imports = [ ./plasma/plasma-work.nix ];

  home.stateVersion = "23.11"; # Please read the comment before changing.

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "electron-29.4.6" ];
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    hello
    cowsay
    neofetch
    manix
    fzf
    vscode
    firefox
    jetbrains.rider
    (with dotnetCorePackages; combinePackages [
      sdk_6_0
      sdk_7_0
      sdk_8_0
    ])
    s3cmd
    slack
    remmina
    vault
    spotify
    terraform
    (writeShellApplication {
      name = "s3preview";
      runtimeInputs = [ s3cmd ];
      text = (builtins.readFile ./work/s3preview.zsh);
    })
    postman
    mpv
    rsync
    ffmpeg_7-full
    iputils
    pbm
    wl-clipboard
    (nerdfonts.override { fonts = [ "FantasqueSansMono" "JetBrainsMono" ]; })
    anki
    teams-for-linux
    bc
    git
    github-cli
    htop
    jq
    man-db
    man-pages
    paru
    tlrc
    less
    shell-gpt
    (pkgs.spotify-player.override {
      withAudioBackend = "pulseaudio";
      withStreaming = true;
      withDaemon = true;
      withMediaControl = true;
      withLyrics = true;
      withImage = true;
      withNotify = true;
      withSixel = true;
    })
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.gyp
      python-pkgs.distutils
    ]))
    nixos-generators
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    syntaxHighlighting.catppuccin.enable = true;

    shellAliases = {
      ll = "ls -l";
      s3prod = "cp $HOME/.s3cfg-prod $HOME/.s3cfg";
      s3stage = "cp $HOME/.s3cfg-stage $HOME/.s3cfg";
      s3test = "cp $HOME/.s3cfg-test $HOME/.s3cfg";
    };

    profileExtra = ''
      unsetopt BEEP
    '';

    initExtra = ''
      source ${./work/scripts.zsh}
      export VAULT_ADDR='https://vault.nrk.cloud:8200'
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      ];
      theme = "robbyrussell";
    };
  };

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true; #declarative in the future? :)
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      yzhang.markdown-all-in-one
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
    ];
    userSettings = {
      # Styling
      "window.autoDetectColorScheme" = true;
      "workbench.preferredDarkColorTheme" = "Catppuccin Frappé";
      "workbench.iconTheme" = "catppuccin-frappe";
    };
  };

  programs.git = {
    enable = true;
    userName = "jimalexberger";
    userEmail = "jim-alexander.berger.seterdahl@nrk.no";
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    shortcut = "Space";
    baseIndex = 1;

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.catppuccin
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.yank
    ];

    extraConfig = ''
      # Colors
      set -ga terminal-overrides ",xterm*:Tc"

      # Mouse support
      set-option -g mouse on

      #New panes in current path
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Catppuccin status bar
      set -g @catppuccin_window_left_separator "█"
      set -g @catppuccin_window_right_separator "█ "
      set -g @catppuccin_window_number_position "right"
      set -g @catppuccin_window_middle_separator "  █"

      set -g @catppuccin_window_default_fill "number"

      set -g @catppuccin_window_current_fill "number"
      set -g @catppuccin_window_current_text "#{pane_current_path}"

      set -g @catppuccin_status_modules_right "application session date_time"
      set -g @catppuccin_status_left_separator  ""
      set -g @catppuccin_status_right_separator " "
      set -g @catppuccin_status_fill "all"
      set -g @catppuccin_status_connect_separator "yes"
    '';
  };

  programs.alacritty = {
    enable = true;
    package = (pkgs.alacritty.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ pkgs.wayland pkgs.pkg-config ];
      enableWayland = true;
    }));
  };

  catppuccin = {
    enable = true;
    flavor = "frappe";
    accent = "blue";

    pointerCursor = {
      enable = true;
      flavor = "frappe";
      accent = "blue";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #for non nix-os systems
  targets.genericLinux.enable = true;

  #Because nixpkgs unstable home-manager neds to accept version miss-match
  home.enableNixpkgsReleaseCheck = false;
}
