{ image_tag ? "" }:

let
  pkgs = import <nixpkgs> {};

  # Generate nixified npm packages using node2nix
  dependencies = (pkgs.callPackage ./node2nix.nix {}).nodeDependencies;
  devDependencies = (pkgs.callPackage ./node2nix.dev.nix {}).nodeDependencies;

  # Create a derivation for the superfluid-sentinel app
  superfluid-sentinel = pkgs.stdenv.mkDerivation rec {
    __noChroot = true;
    pname = "superfluid-sentinel";
    version = "1.0.0";
    src = ./app;  # Path to the source code of the superfluid-sentinel package
    dontConfigure = true;  # Avoid Makefile configuration

    # Link node_modules into the output directory
    buildPhase = ''
      mkdir -p $out/app/node_modules
      cp -r ${dependencies}/lib/node_modules/* $out/app/node_modules
      cp -r ${devDependencies}/lib/node_modules/* $out/app/node_modules
    '';

    # Copy the source code into the output directory and Set the default environment variables
    installPhase = ''
      cp -r . $out/app
      mv $out/app/.env-example $out/app/.env
    '';
  };

  # Build a Docker layer image with the superfluid-sentinel package and other dependencies
  image = pkgs.dockerTools.buildLayeredImage {
    name = "superfluid-sentinel";
    tag = image_tag;
    config = {
      Cmd = [ "node" "main.js" ];
      WorkingDir = "/app";
      Entrypoint = [ "${pkgs.tini}/bin/tini" "--" ];
    };
    contents = [
      superfluid-sentinel
      pkgs.nodejs-16_x
      pkgs.python3
      pkgs.tini
      pkgs.busybox # Include utils for exec into container
    ];
  };

in
  image