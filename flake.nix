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
      inputs.nrk-nix.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, catppuccin, spicetify-nix, sops-nix, disko, nixgl, nrk-nix, ... }@inputs:
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
        nixos = lib.nixosSystem {
          inherit system;
          modules = [ ./machines/personal/configuration.nix ];
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
