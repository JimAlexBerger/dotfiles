{
    description = "JimAlexBergers flake";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-23.11"; # github:NixOS/nixpkgs/nixos-unstable
    };

    
    outputs = {self, nixpkgs, ...}:
    let 
        lib = nixpkgs.lib;
    in {
        nixosConfigurations = {
            nixos = lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ ./configuration.nix ];
            };
        };
    };
}