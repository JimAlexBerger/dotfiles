
# My NIX Dotfiles

## Before running
Make sure to install home manager
### to install home-manager
[https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone)

## Convenient commands

### to update flake

    nix flake update

### to update system

    sudo nixos-rebuild switch --flake .
    sudo nixos-rebuild switch --flake .#configuration

### to update home-manager

    home-manager switch --flake .
    home-manager switch --flake .#configuration
