{ spicetify-nix, sops-nix, ... }:
{ config, pkgs, ... }:
{
  home.username = "n651227";
  home.homeDirectory = "/home/n651227";

  imports = [
    spicetify-nix.homeManagerModules.default
    sops-nix.homeManagerModules.sops
    ./plasma/plasma-work.nix
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
      withImage = true;
      withNotify = true;
      withSixel = true;
    })
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
  ];

  programs.f5vpn.enable = false;
  programs.purpleExplorer.enable = true;

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

    initExtra = ''
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
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
      ];
      userSettings = {
        "window.autoDetectColorScheme" = true;
        "workbench.preferredDarkColorTheme" = "Catppuccin Frappé";
        "workbench.iconTheme" = "catppuccin-frappe";
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

  programs.alacritty = {
    enable = true;
    package = (pkgs.alacritty.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ pkgs.wayland pkgs.pkg-config ];
      enableWayland = true;
    }));
  };

  programs.spicetify =
    let
      spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
    in
    {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        hidePodcasts
        shuffle
        lastfm
        (
          {
            src = pkgs.fetchFromGitHub {
              owner = "BlafKing";
              repo = "spicetify-cat-jam-synced";
              rev = "e7bfd49fcc13457bbc98e696294cf5cf43eb6c31";
              hash = "sha256-pyYa5i/gmf01dkEF9I2awrTGLqkAjV9edJBsThdFRv8=";
            };
            name = "marketplace/cat-jam.js";
          }
        )
      ];
      enabledCustomApps = with spicePkgs.apps; [
        lyricsPlus
        reddit
        marketplace
        betterLibrary
      ];
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "frappe";
    };


  catppuccin = {
    enable = true;
    flavor = "frappe";
    accent = "blue";

    zsh-syntax-highlighting.enable = true;

    cursors = {
      enable = true;
      flavor = "frappe";
      accent = "blue";
    };
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

  #programs.kitty = {
  #  enable = true;
  #  package = "";
  #  font.name = "JetBrainsMono";
  #  shellIntegration.enableZshIntegration = true;
  #  themeFile = "Catppuccin-Frappe";
  #};

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #for non nix-os systems
  targets.genericLinux.enable = true;

  #Because nixpkgs unstable home-manager neds to accept version miss-match
  home.enableNixpkgsReleaseCheck = false;
}
