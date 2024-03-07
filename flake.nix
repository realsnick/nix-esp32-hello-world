{
  description = "Rust Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
  };

  outputs =
    { nixpkgs
    , flake-utils
    , rust-overlay
    , nixpkgs-esp-dev
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
            (import "${nixpkgs-esp-dev}/overlay.nix")
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
          rustup
          rust-analyzer
          cargo-generate
          cargo-espflash
          cargo-espmonitor

          # slint dependencies
          cmake
          pkg-config
          fontconfig
          xorg.libxcb
          wayland
          libxkbcommon
          libGL
          # esp-idf-sys dependencies:
          cmake
          ninja
          python3Packages.python
          python3Packages.pip
          python3Packages.virtualenv
        ];

      in
      {
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs buildInputs;
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}";
        };

        packages.default = rustPlatform.buildRustPackage rec {
          inherit name;
          inherit buildInputs;
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };
      }
    );
}



