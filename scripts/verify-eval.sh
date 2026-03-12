#!/usr/bin/env bash
# verify-eval.sh - Ensures all flake outputs evaluate correctly without building

set -e

echo "🔍 Evaluating all flake outputs..."

# 1. Home Manager Configurations
HOMES=$(nix eval .#homeConfigurations --json --apply 'builtins.attrNames' | jq -r '.[]')
for home in $HOMES; do
    echo "  - Evaluating homeConfiguration: $home"
    nix eval .#homeConfigurations."$home".activationPackage.outPath --show-trace > /dev/null
done

# 2. NixOS Configurations
MACHINES=$(nix eval .#nixosConfigurations --json --apply 'builtins.attrNames' | jq -r '.[]')
for machine in $MACHINES; do
    echo "  - Evaluating nixosConfiguration: $machine"
    nix eval .#nixosConfigurations."$machine".config.system.build.toplevel.outPath --show-trace > /dev/null
done

echo "✅ All outputs evaluated successfully!"
