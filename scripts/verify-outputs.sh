#!/usr/bin/env bash
# verify-outputs.sh - Ensures all flake outputs evaluate correctly

set -e

echo "🔍 Checking all flake outputs..."

# 1. Syntax & Basic Flake Structure
nix flake check --no-build

# 2. Home Manager Configurations
HOMES=$(nix eval .#homeConfigurations --attr-names --json | jq -r '.[]')
for home in $HOMES; do
    echo "  - Evaluating homeConfiguration: $home"
    nix eval .#homeConfigurations."$home".activationPackage.outPath --show-trace > /dev/null
done

# 3. NixOS Configurations
MACHINES=$(nix eval .#nixosConfigurations --attr-names --json | jq -r '.[]')
for machine in $MACHINES; do
    echo "  - Evaluating nixosConfiguration: $machine"
    nix eval .#nixosConfigurations."$machine".config.system.build.toplevel.outPath --show-trace > /dev/null
done

echo "✅ All outputs evaluated successfully!"
