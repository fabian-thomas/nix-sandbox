{ pkgs ? import <nixpkgs> {}
, pkgs-unstable ?
    # Try to import <nixpkgs-unstable> with fallback to <nixpkgs>
    let unstableImport = builtins.tryEval (import <nixpkgs-unstable> {});
    in if unstableImport.success then unstableImport.value else pkgs
}:
pkgs.mkShell {
  packages = with pkgs; [
    git
    ripgrep
    fd
    jq
    bash
    coreutils
    gcc
    gdb
    strace
    binutils
    pkg-config
    cmake
    gnused
    gnugrep
    findutils
    gnumake
    tree
    wget
    curl
    file
    which
    python3
    python3Packages.pyyaml
    python3Packages.requests
    python3Packages.click
    python3Packages.rich
    python3Packages.pytest
    direnv
    nix
    pkgs-unstable.opencode
    # v1.1.53
    # (builtins.getFlake "github:anomalyco/opencode?rev=8ad5262a87e00ba9ee8ca9bde0b04d40024b37d4").packages.${builtins.currentSystem}.default
    pkgs-unstable.codex
    # (builtins.getFlake "github:openai/codex/rust-v0.84.0").packages.${builtins.currentSystem}.default
  ];
}
