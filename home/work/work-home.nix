{ config, pkgs, ... }:

{
  home.username = "n651227";
  home.homeDirectory = "/home/n651227";

  imports = [
    ../desktop-environments/hyprland/hyprland.nix
    ../config/waybar.nix
    ../config/nixvim/nixvim.nix
    ./freerdp.nix
  ];

  home.stateVersion = "23.11"; # Please read the comment before changing.

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-29.4.6"
      "dotnet-sdk-7.0.410"
      "dotnet-sdk-6.0.428"
    ];
  };

  nix.package = pkgs.nix;
  nix.settings =
    {
      extra-experimental-features = [ "nix-command" "flakes" ];
    };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    hello
    cowsay
    neofetch
    manix
    fzf
    vscode
    jetbrains.rider
    (with dotnetCorePackages; combinePackages [
      sdk_9_0
      sdk_8_0
      sdk_6_0
    ])
    s3cmd
    slack
    remmina
    vault-bin
    terraform
    (writeShellApplication {
      name = "s3preview";
      runtimeInputs = [ s3cmd ];
      text = (builtins.readFile ./work/s3preview.sh);
    })
    (writeShellApplication {
      name = "s3find";
      runtimeInputs = [ s3cmd ];
      text = (builtins.readFile ./work/s3find.sh);
    })
    postman
    mpv
    rsync
    ffmpeg_7-full
    iputils
    pbm
    wl-clipboard
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.jetbrains-mono
    noto-fonts-emoji
    dejavu_fonts
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
    nixos-generators
    lazydocker
    atac
    dbeaver-bin
    sq
    obsidian
    pv
    yt-dlp
    darktable
    age
    sops
    pre-commit
    nixos-rebuild
    mkpasswd
    element-desktop
    bluetui
    nixgl.nixGLIntel
    azure-cli
    kubelogin
    kubectl
    kubectx
    k9s
    direnv
    pulsemixer
    google-cloud-sdk
    nix-output-monitor
    nh
    traceroute
    wofi
    kdePackages.konsole
    nerdfix
    imagemagick
  ];

  programs.kitty = {
    enable = true;
    package = pkgs.emptyDirectory; # Force settings to be handled by home manager, but installation of package from arch / nixos
  };

  programs.btop.enable = true;
  programs.fastfetch.enable = true;

  programs.purpleExplorer.enable = true;

  home.sessionVariables = {
    NH_FLAKE = "/home/n651227/repos/dotfiles";
  };

  sops = {
    age.keyFile = "/home/n651227/.config/sops/age/keys.txt";

    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";

    secrets.test_secret.path = "${config.sops.defaultSymlinkPath}/test_secret";
    secrets.NRK_GITHUB_TOKEN.path = "${config.sops.defaultSymlinkPath}/NRK_GITHUB_TOKEN";
    secrets.PHOBOS_NUGET_USERNAME.path = "${config.sops.defaultSymlinkPath}/PHOBOS_NUGET_USERNAME";
    secrets.PHOBOS_NUGET_PASSWORD.path = "${config.sops.defaultSymlinkPath}/PHOBOS_NUGET_PASSWORD";

    secrets.s3cfg-prod = {
      format = "binary";
      sopsFile = ../../secrets/s3-configs/s3cfg-prod;
    };

    secrets.s3cfg-stage = {
      format = "binary";
      sopsFile = ../../secrets/s3-configs/s3cfg-stage;
    };

    secrets.s3cfg-test = {
      format = "binary";
      sopsFile = ../../secrets/s3-configs/s3cfg-test;
    };

    secrets.atuin-key = {
      format = "binary";
      sopsFile = ../../secrets/atuin/.atuin-key;
    };

    secrets."vpn-cert.p12" = {
      format = "binary";
      sopsFile = ../../secrets/certs/n651227-vpn.p12;
    };

    secrets."nrk_ca.crt" = {
      format = "binary";
      sopsFile = ../../secrets/certs/nrk_ca.crt;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      s3prod = "cp ${config.sops.secrets.s3cfg-prod.path} $HOME/.s3cfg";
      s3stage = "cp ${config.sops.secrets.s3cfg-stage.path} $HOME/.s3cfg";
      s3test = "cp ${config.sops.secrets.s3cfg-test.path} $HOME/.s3cfg";
    };

    profileExtra = ''
      unsetopt BEEP
    '';

    initContent = ''
      source ${./work/scripts.zsh}
      export VAULT_ADDR='https://vault.nrk.cloud:8200'
      export TEST_SECRET=$(cat ${config.sops.secrets.test_secret.path})
      export NRK_GITHUB_TOKEN=$(cat ${config.sops.secrets.NRK_GITHUB_TOKEN.path})
      export PHOBOS_NUGET_USERNAME=$(cat ${config.sops.secrets.PHOBOS_NUGET_USERNAME.path})
      export PHOBOS_NUGET_PASSWORD=$(cat ${config.sops.secrets.PHOBOS_NUGET_PASSWORD.path})
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
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        yzhang.markdown-all-in-one
        # catppuccin.catppuccin-vsc
        # catppuccin.catppuccin-vsc-icons
      ];
      userSettings = {
        "git.enableSmartCommit" = "true";
      };
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

  programs.firefox = {
    enable = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    daemon.enable = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      key_path = config.sops.secrets.atuin-key.path;
      auto_sync = true;
      sync_frequency = "5m";
      enter_accept = false;
      update_check = false;
    };
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };



  programs.spotify-player = {
    enable = true;
    package = (pkgs.spotify-player.override {
      withAudioBackend = "pulseaudio";
      withStreaming = true;
      withDaemon = true;
      withMediaControl = true;
      withImage = true;
      withNotify = true;
      withSixel = true;
    });
  };

  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";

    image = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/d8/wallhaven-d8xpxo.jpg";
      sha256 = "sha256-TQryBkLHNqnYoeya4lYPCE2D4qhj3okB3bSfuN2Fkn0=";
    };

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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #for non nix-os systems
  targets.genericLinux.enable = true;

  #Because nixpkgs unstable home-manager neds to accept version miss-match
  home.enableNixpkgsReleaseCheck = false;
}
