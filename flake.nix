{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    naersk.url = "github:nix-community/naersk";

    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    naersk,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        buildPackage = naersk.lib.${system}.buildPackage;
      in rec {
        packages.default = buildPackage {
          src = ./.;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [packages.default];
          packages = with pkgs; [rustc rustfmt clippy];
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };

        formatter = pkgs.alejandra;
      }
    );
}
