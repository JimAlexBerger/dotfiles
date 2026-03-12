# Dotfiles Refactoring Roadmap

This document outlines the planned improvements for the dotfiles repository to enhance modularity, reduce redundancy, and improve maintainability.

## 1. Directory Restructuring & Standardization
**Current State:** Mixed usage of `home/config`, `home/desktop-environments`, and `modules/`.
**Target State:**
- `hosts/`: Machine-specific NixOS configurations (currently in `machines/`).
- `home/profiles/`: Top-level Home Manager entry points (e.g., `work.nix`, `personal.nix`).
- `home/modules/`: Feature-specific Home Manager modules (e.g., `zsh/`, `git/`, `vscode/`).
- `modules/nixos/`: Shared NixOS-level modules.
- `pkgs/`: Custom scripts and derivations.

## 2. Shared Base Configuration
**Objective:** Eliminate duplication between `personal/home.nix` and `work/work-home.nix`.
- Create `home/modules/common/default.nix` containing shared packages and program settings (Kitty, Btop, Fastfetch, Starship).
- Refactor `zsh`, `git`, and `vscode` into standalone modules that can be toggled with options.

## 3. Modularizing `work-home.nix`
**Objective:** Break down the 300+ line file into manageable parts.
- Extract `sops` configuration to `home/modules/secrets/sops.nix`.
- Extract package lists to `home/modules/profiles/work-packages.nix`.
- Extract Zsh init logic and aliases to `home/modules/shell/zsh.nix`.

## 4. Secret Management (SOPS) Optimization
**Objective:** Reduce boilerplate for exporting secrets to the environment.
- Create a helper module that automatically maps a list of SOPS secrets to environment variables.
- Remove manual `cat` commands from Zsh `initContent`.

## 5. Nixvim Cleanup
**Objective:** Transform the "Kickstart" boilerplate into a personal, clean configuration.
- Remove excessive "Kickstart" tutorial comments.
- Move plugin-specific logic from `home/config/nixvim/default.nix` into a cleaner structure.
- Ensure all plugin files are actually imported and utilized.

## 6. [DONE] Abstracting Hardcoded Paths
**Objective:** Ensure portability across different machines and usernames.
- [x] Replace `/home/n651227` and `/home/jimalexberger` with `${config.home.homeDirectory}`.
- [x] Replace relative path strings with proper Nix path types where possible.

## 7. Custom Scripts & Derivations
**Objective:** Improve build reproducibility and organization.
- Move `s3find.sh` and `s3preview.sh` into `pkgs/s3utils/`.
- Convert `purpleExplorer.nix` and `pomodoro-cli.nix` into standard `callPackage` patterns.

## 8. Flake Optimization
**Objective:** Clean up `flake.nix` outputs.
- Use `flake-utils` or a custom helper function to generate `nixosConfigurations` and `homeConfigurations`.
- Reduce the size of the `let ... in` block by moving overlays and logic to separate files.
