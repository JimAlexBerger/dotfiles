{
  description = "JimAlexBergers flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable"; # nixos-unstable
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nrk-nix = {
      url = "git+ssh://git@github.com/nrkno/linux-hylla.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.gnome-shell.url = "github:GNOME/gnome-shell/ef02db02bf0ff342734d525b5767814770d85b49";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, disko, nixgl, nrk-nix, stylix, nixvim, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs-stable = import inputs.nixpkgs-stable { inherit system; };
      stable-overlay =
        final: prev: {
          azure-cli = pkgs-stable.azure-cli;
        };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nixgl.overlay
          stable-overlay
        ];
      };
    in
    {
      nixosConfigurations = {
        aurvandil = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup2";
              home-manager.users.jimalexberger = {
                imports = [ ./home/personal/home.nix ];
              };
            }
            ./machines/personal/aurvandil/configuration.nix
          ];
        };
        nrklx75718-vm = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            stylix.nixosModules.stylix
            nrk-nix.nixosModules
            ./machines/work/configuration.nix
          ];
        };
        reticulum = lib.nixosSystem {
          inherit system;
          modules = [
            ./machines/personal/reticulum/configuration.nix
            ./machines/personal/reticulum/hardware-configuration.nix
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                sops-nix.homeManagerModules.sops
                nixvim.homeModules.nixvim
              ];
              home-manager.users.jimalexberger = {
                imports = [ ./home/personal/server-user.nix ];
              };
            }
          ];
        };
      };
      homeConfigurations = {
        jimalexberger = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            stylix.homeModules.stylix
            ./home/personal/home.nix
          ];
        };
        n651227 = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            stylix.homeModules.stylix
            sops-nix.homeManagerModules.sops
            nixvim.homeModules.nixvim
            ./modules/homeManagerModules
            ./home/work/work-home.nix
          ];
        };
      };
      packages.${system}.pomodoro-cli = pkgs.callPackage ./modules/applications/pomodoro-cli.nix { };
    };
}
