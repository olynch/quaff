{ pkgs ? import <nixpkgs> { } }:

let
  stdenv = pkgs.stdenv;
in
  stdenv.mkDerivation {
    name = "quaff";
    buildInputs = with pkgs; [
      beam.packages.erlangR20.elixir
      beam.packages.erlangR20.erlang
    ];

    shellHook = "export ERL_AFLAGS='-kernel shell_history enabled'";
  }
