{ config
, modulesPath
, lib
, pkgs
, ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "reticulum";

  time.timeZone = "Europe/Oslo";

  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "no";
    variant = "";
  };

  nixpkgs.config.allowUnfree = true;

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  sops = {
    age.keyFile = "/home/n651227/.config/sops/age/keys.txt";

    defaultSopsFile = ../../../secrets/secrets.yaml;

    secrets.test_secret = { };
    secrets.user_password_hash.neededForUsers = true;
  };

  users.users.jimalexberger = {
    isNormalUser = true;
    description = "Jim-Alexander Berger Seterdahl";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [ ];
    hashedPasswordFile = config.sops.secrets.user_password_hash.path;
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets.user_password_hash.path;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/Mdw+B6hzwwPJ7SvUdsUB6GreZ9K7Vq03cpUCYKViU"
  ];

  system.stateVersion = "24.05";
}
