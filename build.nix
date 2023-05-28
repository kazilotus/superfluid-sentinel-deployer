# This script creates a Docker image for the application.
# It bypasses the sandbox restriction in Nix to build the image because of issues encountered with node2nix.
# This approach installs dependencies directly using npm with internet access.
# Compared to the node2nix version of the image, this approach produces an image that is around 200mb in size (versus 320mb) and takes only 5 minutes to build (versus 10 minutes).


{ 
  image_tag ? "",
  pkgs ? import <nixpkgs> { },
  nix-filter ? import (builtins.fetchTarball "https://github.com/numtide/nix-filter/archive/main.tar.gz")
}:

let self =
{

  nodejs = pkgs.nodejs-16_x;
  python = pkgs.python3;

  modules = pkgs.stdenv.mkDerivation {
    name = "node_modules";
    src = nix-filter {
      root = ./app;
      include = [ "package.json" "package-lock.json" ];
    };
    
    __noChroot = true;

    configurePhase = ''
      # NPM writes cache directories etc to $HOME.
      export HOME=$TMP
    '';

    buildInputs = [ self.nodejs self.python ];

    buildPhase = ''
      ${self.nodejs}/bin/npm ci
    '';

    installPhase = ''
      mkdir $out
      mv node_modules $out/node_modules
    '';
  };

  src = pkgs.stdenv.mkDerivation {
    name = "superfluid-sentinel";
    version = "1.0.0";
    src = nix-filter {
      root = ./app;
      exclude = [ "node_modules" ];
    };

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/app
      cp -r . $out/app
      ln -sf ${self.modules}/node_modules $out/app/node_modules
      mv $out/app/.env-example $out/app/.env
    '';
  };

  image = pkgs.dockerTools.buildLayeredImage {
    name = "superfluid-sentinel";
    tag = image_tag;
    config = {
      Cmd = [ "node" "main.js" ];
      WorkingDir = "/app";
      Entrypoint = [ "${pkgs.tini}/bin/tini" "--" ];
    };
    contents = [
      self.src
      self.nodejs
      pkgs.tini
      pkgs.busybox # Include utils for exec into container
    ];
  };
  
}; in self