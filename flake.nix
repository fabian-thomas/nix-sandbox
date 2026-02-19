{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
        nixSandbox = pkgs.callPackage ./default.nix { };
        sandboxApp = {
          type = "app";
          program = "${nixSandbox}/bin/nix-sandbox";
        };
      in {
        devShells = {
          default = pkgs.mkShell {
            packages = nixSandbox.passthru.runtimeDependencies;
          };
          sandbox = import ./shell.nix {
            inherit pkgs pkgs-unstable;
          };
        };

        packages = {
          nix-sandbox = nixSandbox;
          default = nixSandbox;
        };

        apps = {
          nix-sandbox = sandboxApp;
          default = sandboxApp;
        };
      });
}
