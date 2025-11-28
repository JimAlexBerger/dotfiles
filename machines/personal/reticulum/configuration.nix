# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "jimalexberger" ];

  boot.kernelPackages = latestKernelPackage;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "f6b9daab";

  networking.hostName = "reticulum"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "no";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "no";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jimalexberger = {
    isNormalUser = true;
    description = "jim-alexander berger seterdahl";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/Mdw+B6hzwwPJ7SvUdsUB6GreZ9K7Vq03cpUCYKViU"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEc78BxN5BQqFa1pyQx2PqXVxxBcWtc/H64yfOSCcQmP"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5fyEoIivr8pNPY2NlPanp3OMvDaJg7uwo3zwODVyZT"
    ];
  };

  programs.zsh.enable = true;

  services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/lacaille/immich/immich";
  };

  services.unifi = {
    enable = true;
    openFirewall = true;
  };

  services.couchdb = {
    enable = true;
    databaseDir = "/lacaille/couchdb";
    bindAddress = "0.0.0.0";
    adminUser = "admin";
    adminPass = "password";
  };

  services.traefik = {
    enable = true;

    staticConfigOptions = {
      api.dashboard = true;
      entryPoints.web.address = ":80";
      entryPoints.websecure.address = ":443";
      certificatesResolvers = {
        myresolver = {
          tailscale = {};
        };
      };
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          dashboard = {
            rule = "Host(`reticulum.tailfed576.ts.net`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))";
            service = "api@internal";
            tls.certResolver = "myresolver";
          };
          immich = {
            rule = "Host(`immich.tailfed576.ts.net`)";
            service = "immich";
            tls.certResolver = "myresolver";
          };
        };
      };
      services = {
        immich.loadBalancer.servers = [ { url = "http://localhost:2283"; } ];
      };
    };
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "jimalexberger";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    gh
    ntfs3g
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-sice 14d --keep 10";
    flake = "/home/jimalexberger/repos/dotfiles";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "jimalexberger" ];
    };
  };

  services.tailscale = {
    enable = true;
    permitCertUid = "traefik";
  };

  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    openFirewallDHCP = true;
    openFirewallWebserver = true;
    settings = {
      dns = {
        upstreams = [ "8.8.8.8" "8.8.4.4" ];
      };
    };
    lists = 
      [
        {
          url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt";
        }
        {
          url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/NorwegianExperimentalList%20alternate%20versions/DandelionSproutsNorskeFiltre.tpl";
        }
      ];
  };

  services.pihole-web = {
    enable = true;
    hostName = "reticulum";
    ports = [ "8090r" "8091s" ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 443 2283 5984 ];
  networking.firewall.allowedUDPPorts = [ 80 443 2283 5984 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
