{ pkgs ? import <nixpkgs> { } }:

let
  stdenv = pkgs.stdenv;
in
  stdenv.mkDerivation {
    name = "quaff";
    buildInputs = with pkgs; [
      elixir
      erlang
    ];
  }
