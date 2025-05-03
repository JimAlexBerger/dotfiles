{
  description = "JimAlexBergers flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable"; # nixos-unstable
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
    };
    nrk-nix = {
      url = "git+ssh://git@github.com/nrkno/linux-hylla.git?ref=feature/nix-f5vpn";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, catppuccin, spicetify-nix, sops-nix, disko, nixgl, nrk-nix, stylix, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nixgl.overlay ];
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
              home-manager.backupFileExtension = "backup";
              home-manager.users.jimalexberger = {
                imports = [ ./home/personal/home.nix ];
              };
            }
            ./machines/personal/aurvandil/configuration.nix 
          ];
        };
        nrklx75718-vm = lib.nixosSystem {
          inherit system;
          modules = [
            nrk-nix.nixosModules
            ./machines/work/configuration.nix
          ];
        };
        reticulum = lib.nixosSystem {
          inherit system;
          modules = [
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            ./machines/personal/reticulum/configuration.nix
            ./machines/personal/reticulum/hardware-configuration.nix
          ];
        };
      };
      homeConfigurations = {
        jimalexberger = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            stylix.homeManagerModules.stylix
            ./home/personal/home.nix
          ];
        };
        n651227 = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            catppuccin.homeModules.catppuccin
            plasma-manager.homeManagerModules.plasma-manager
            ./modules/homeManagerModules
            (import ./home/work/work-home.nix inputs)
          ];
        };
      };
    };
}
