{
  description = "Rust Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    { nixpkgs
    , flake-utils
    , rust-overlay
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit ((builtins.fromTOML (builtins.readFile ./Cargo.toml)).package) name;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
          ];
        };

        toolchain =
          (
            pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml
          );

        rustPlatform =
          let
            pkgsCross = import nixpkgs {
              inherit system;
              crossSystem = {
                inherit system;
                rustc.config = "riscv32imc-unknown-none-elf";
              };
            };
          in
          pkgsCross.makeRustPlatform
            {
              rustc = toolchain;
              cargo = toolchain;
            };

        nativeBuildInputs = with pkgs; [
          cargo-espflash
          toolchain
        ];

        buildInputs = with pkgs; [
          rust-analyzer
        ];
      in
      {
        devShells.default = pkgs.mkShell { inherit nativeBuildInputs buildInputs; };


        packages.default = rustPlatform.buildRustPackage rec {
          inherit name;
          inherit buildInputs;
          # inherit nativeBuildInputs;
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };
      }
    );
}
