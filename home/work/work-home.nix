{ config, pkgs, ... }:

{
  home.username = "n651227";
  home.homeDirectory = "/home/n651227";

  imports = [
    ../desktop-environments/hyprland

    ./rdpwork

    ../config/waybar
    ../config/nixvim
    ../config/tmux
    ../config/stylix
    ../config/khal
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
      builders = "ssh://jimalexberger@reticulum x86_64-linux /home/n651227/.ssh/id_ed25519";
      builders-use-substitutes = true;
      trusted-users = [ "@wheel" ];
    };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    neofetch
    manix
    fzf
    vscode
    (jetbrains.rider.override {
      jdk = jdk;
    })
    (with dotnetCorePackages; combinePackages [
      sdk_9_0
      sdk_8_0
      sdk_6_0
    ])
    s3cmd
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
    noto-fonts-color-emoji
    dejavu_fonts
    teams-for-linux
    git
    github-cli
    htop
    jq
    man-db
    man-pages
    tlrc
    shell-gpt
    lazydocker
    dbeaver-bin
    obsidian
    pv
    age
    sops
    pre-commit
    mkpasswd
    element-desktop
    bluetui
    nixgl.nixGLIntel
    kubelogin
    kubectl
    kubectx
    k9s
    pulsemixer
    google-cloud-sdk
    nix-output-monitor
    nh
    traceroute
    wofi
    nerdfix
    imagemagick
    jaq
    bat
    (callPackage ../../modules/applications/pomodoro-cli.nix { })
    vim
    gemini-cli
    nixpkgs-review
    nyxt
    azure-cli
    (pkgs.runCommand "psql" { } ''
      mkdir -p $out/bin
      ln -s ${pkgs.postgresql}/bin/psql $out/bin/psql
    '')
    darktable
    ladybird
    virt-manager
    immich-cli
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

    secrets.gemini_api_key.path = "${config.sops.defaultSymlinkPath}/gemini_api_key";

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

    secrets."vpn-cert.pfx" = {
      format = "binary";
      sopsFile = ../../secrets/certs/n651227-vpn.pfx;
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

      export LIBVIRT_DEFAULT_URI="qemu:///system"

      export VAULT_ADDR='https://vault.nrk.cloud:8200'
      export TEST_SECRET=$(cat ${config.sops.secrets.test_secret.path})
      export NRK_GITHUB_TOKEN=$(cat ${config.sops.secrets.NRK_GITHUB_TOKEN.path})
      export PHOBOS_NUGET_USERNAME=$(cat ${config.sops.secrets.PHOBOS_NUGET_USERNAME.path})
      export PHOBOS_NUGET_PASSWORD=$(cat ${config.sops.secrets.PHOBOS_NUGET_PASSWORD.path})
      export GEMINI_API_KEY=$(cat ${config.sops.secrets.gemini_api_key.path})
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker-compose"
        "dotnet"
        "ssh-agent"
        "tmux"
      ];
      theme = "robbyrussell";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.nushell = {
    enable = true;
    extraConfig = ''
      $env.PATH ++= [ "~/.nix-profile/bin" ]
    '';
    shellAliases = {
      ll = "ls -l";
      s3prod = "cp ${config.sops.secrets.s3cfg-prod.path} ~/.s3cfg";
      s3stage = "cp ${config.sops.secrets.s3cfg-stage.path} ~/.s3cfg";
      s3test = "cp ${config.sops.secrets.s3cfg-test.path} ~/.s3cfg";
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
    settings = {
      user.name = "jimalexberger";
      user.email = "jim-alexander.berger.seterdahl@nrk.no";
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

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "jim-alexander.berger.seterdahl@nrk.no";
        name = "Jim-Alexander Berger Seterdahl";
      };
      aliases = {
        tug = [ "bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-" ];
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #for non nix-os systems
  targets.genericLinux.enable = true;

  #Because nixpkgs unstable home-manager neds to accept version miss-match
  home.enableNixpkgsReleaseCheck = false;
}
