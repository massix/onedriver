{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.pkg-config
          ];

          packages = with pkgs; [
            go
            gopls
            glib
            gofumpt
            goimports-reviser
            gotools
            fuse
            webkitgtk_4_1
          ];
        };

        packages.default = pkgs.buildGoModule rec {
          pname = "onedriver";
          version = "master";

          src = builtins.path {
            name = "onedriver-source";
            path = toString ./.;
          };

          vendorHash = "sha256-OOiiKtKb+BiFkoSBUQQfqm4dMfDW3Is+30Kwcdg8LNA=";

          nativeBuildInputs = with pkgs; [
            pkg-config
            installShellFiles
          ];

          buildInputs = with pkgs; [
            webkitgtk_4_1
            glib
            fuse
          ];

          ldflags = ["-X github.com/jstaf/onedriver/cmd/common.commit=v${version}"];

          subPackages = [
            "cmd/onedriver"
            "cmd/onedriver-launcher"
          ];

          postInstall = ''
            echo "Running postInstall"
            install -Dm644 ./pkg/resources/onedriver.svg $out/share/icons/onedriver/onedriver.svg
            install -Dm644 ./pkg/resources/onedriver.png $out/share/icons/onedriver/onedriver.png
            install -Dm644 ./pkg/resources/onedriver-128.png $out/share/icons/onedriver/onedriver-128.png

            install -Dm644 ./pkg/resources/onedriver.desktop $out/share/applications/onedriver.desktop

            mkdir -p $out/share/man/man1
            installManPage ./pkg/resources/onedriver.1

            substituteInPlace $out/share/applications/onedriver.desktop \
              --replace "/usr/bin/onedriver-launcher" "$out/bin/onedriver-launcher" \
              --replace "/usr/share/icons" "$out/share/icons"
          '';

          doCheck = false;
        };
      }
    );
}
