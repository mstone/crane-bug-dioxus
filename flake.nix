{
  description = "Build a cargo project with a custom toolchain";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, crane, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        rustWithWasiTarget = pkgs.rust-bin.stable.latest.default.override {
          targets = [ "wasm32-unknown-unknown" ];
        };

        # NB: we don't need to overlay our custom toolchain for the *entire*
        # pkgs (which would require rebuidling anything else which uses rust).
        # Instead, we just want to update the scope that crane will use by appending
        # our specific toolchain there.
        craneLib = (crane.mkLib pkgs).overrideToolchain rustWithWasiTarget;

        my-crate = craneLib.buildPackage {
          src = ./.;

          cargoExtraArgs = "--target wasm32-unknown-unknown";

          # Tests currently need to be run via `cargo wasi` which
          # isn't packaged in nixpkgs yet...
          doCheck = false;

          buildInputs = [
            # Add additional build inputs here
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            # Additional darwin specific inputs can be set here
            pkgs.libiconv
          ];
        };

        wasm = pkgs.stdenv.mkDerivation {
          name = "wasm";
          src = self;
          phases = [ "buildPhase" "installPhase" ];
          buildInputs = [
            pkgs.wasm-bindgen-cli
          ];
          buildPhase = ''
            cp ${my-crate}/bin/crane-bug-dioxus.wasm web.wasm
            mkdir pkg
            wasm-bindgen --target web --out-dir pkg web.wasm
          '';
        };
      in
      {
        checks = {
          inherit my-crate;
        };

        packages.default = wasm;

        apps.default = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "my-app" ''
            ${pkgs.python3}/bin/python3 -m http.server -d ${wasm} 8080
          '';
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.checks;

          # Extra inputs can be added here
          nativeBuildInputs = with pkgs; [
            rustWithWasiTarget
          ];
        };
      });
}
