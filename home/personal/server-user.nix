{ config, pkgs, ... }:

{
  home.username = "jimalexberger";
  home.homeDirectory = "/home/jimalexberger";

  imports = [
    ../config/khal
    ../config/nixvim
    ../config/tmux
  ];

  home.stateVersion = "25.05"; # Please read the comment before changing.

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
    ];
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    neofetch
    manix
    fzf
    rsync
    iputils
    pbm
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
    dejavu_fonts
    git
    github-cli
    htop
    jq
    man-db
    man-pages
    pv
    age
    sops
    pre-commit
    mkpasswd
    bluetui
    nix-output-monitor
    nh
    traceroute
    vim
    zfs
    aria2
    file
    unzip
  ];

  programs.btop.enable = true;
  programs.fastfetch.enable = true;

  home.sessionVariables = {
    NH_FLAKE = "/home/jimalexberger/repos/dotfiles";
  };

  sops = {
    age.keyFile = "/home/jimalexberger/.config/sops/age/keys.txt";

    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";

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
    };

    profileExtra = ''
      unsetopt BEEP
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker-compose"
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

  programs.git = {
    enable = true;
    settings = {
      user.name = "jimalexberger";
      user.email = "alexandergundersen@yahoo.no";
    };
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

  #Because nixpkgs unstable home-manager neds to accept version miss-match
  home.enableNixpkgsReleaseCheck = false;
}
