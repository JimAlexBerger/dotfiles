{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "n651227";
  home.homeDirectory = "/home/n651227";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
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
    kdePackages.spectacle
    (writeShellApplication {
      name = "s3preview";
      runtimeInputs = [ s3cmd ];
      text = (builtins.readFile ./work/s3preview.zsh);
    })
    postman
    mpv
    rsync
    ffmpeg_7-full

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jimalexberger/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      s3prod = "cp $HOME/.s3cfg-prod $HOME/.s3cfg";
      s3stage = "cp $HOME/.s3cfg-stage $HOME/.s3cfg";
      s3test = "cp $HOME/.s3cfg-test $HOME/.s3cfg";
    };
    
    profileExtra = ''
      unsetopt BEEP
    '';

    initExtra = "source ${./work/scripts.zsh}";

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
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      yzhang.markdown-all-in-one
    ];
  };

  programs.git = {
    enable = true;
    userName = "jimalexberger";
    userEmail = "jim-alexander.berger.seterdahl@nrk.no";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  #for non nix-os systems
  targets.genericLinux.enable = true;

  #Because nixpkgs unstable home-manager neds to accept version miss-match
  home.enableNixpkgsReleaseCheck = false;
}
