{pkgs}:
with pkgs;
let
  src = ./.;
  nodeEnv = pkgs.stdenv.mkDerivation {
    name = "node-env";
    src = src;
    buildInputs = [
      pkgs.nodejs-14_x
      (import ./default.nix {i})
    ];
  };
in
  pkgs.mkShell {
    buildInputs = [
      nodeEnv
    ];

  }