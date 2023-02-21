with import <nixpkgs> {};

let
  pkgs = import "${fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-21.11.tar.gz}" {};

  py = import ./utils/nix/python/py.nix {requirementsFile=./utils/python/requirements.txt;};

  pg = import ./utils/nix/pypg/pypg.nix {postgres = postgresql_15; requirementsFile = ./utils/python/requirements.txt; pkgs=pkgs;};
in
with pkgs;
pkgs.mkShell {

  name = "pg-shell";
  buildInputs = with pkgs;[
    py
    pg
    nodejs
  ];
  shellHook = ''
  . ${./utils/sh/shell-hook.sh} ${py}
  '';
}