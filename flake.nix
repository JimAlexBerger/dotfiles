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
  };


  outputs = { self, nixpkgs, home-manager, plasma-manager, catppuccin, spicetify-nix, sops-nix, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ./machines/work/configuration.nix
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
            catppuccin.homeManagerModules.catppuccin
            plasma-manager.homeManagerModules.plasma-manager
            (import ./home/work/work-home.nix inputs)
          ];
        };
      };
    };
}
