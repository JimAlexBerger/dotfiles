{
  description = "JimAlexBergers flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable"; # nixos-unstable
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };


  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          modules = [ ./configuration.nix ];
        };
      };
      homeConfigurations = {
        jimalexberger = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
          ];
        };
        n651227 = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            plasma-manager.homeManagerModules.plasma-manager
            ./work-home.nix
          ];
        };
      };
    };
}
