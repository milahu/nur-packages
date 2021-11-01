/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'

based on
https://github.com/xddxdd/nur-packages/tree/812de98e6b0080c85a4a94e289fa0425165b7c3b/pkgs/linux-xanmod-lantian
*/

{ stdenv
, lib
, fetchFromGitHub
, linuxManualConfig
, linuxKernel
#, kernelPatches ? []
, writeTextFile
, fetchurl
}:

let
  baseKernel = linuxKernel.packageAliases.linux_latest.kernel;

  # https://github.com/firecracker-microvm/firecracker/blob/main/resources/microvm-kernel-x86_64.config
  configfile-rev = "9b03e30a92c48be7fc061a46571e99862eaa1fd8";
  configfile-sha256 = "AEbQtRD7cWWJIzynEorT35wrfZrHnbSJ8a0wkC8wliE=";

  configfile = fetchurl {
    url = "https://github.com/firecracker-microvm/firecracker/raw/${configfile-rev}/resources/microvm-kernel-x86_64.config";
    sha256 = configfile-sha256;
    # FIXME? replace variable $UNAME_RELEASE: CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
  };

  # https://github.com/xddxdd/nur-packages/blob/812de98e6b0080c85a4a94e289fa0425165b7c3b/pkgs/linux-xanmod-lantian/gen_config_nix.sh
  config = import (stdenv.mkDerivation {
    name = "kernel-config.nix";
    phases = "buildPhase";
    buildPhase = ''
      #!/bin/sh
      echo "debug: parsing nix attrset from configfile ${configfile}"
      echo "{" > $out
      while IFS='=' read key val; do
        [ "x''${key#CONFIG_}" != "x$key" ] || continue
        no_firstquote="''${val#\"}";
        echo '  "'"$key"'" = "'"''${no_firstquote%\"}"'";' >> $out
      done < ${configfile}
      echo "}" >> $out
    '';
  });
in

# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
linuxManualConfig rec {
  inherit stdenv lib config configfile;
  inherit (baseKernel) version src;

  kernelPatches = baseKernel.kernelPatches;

  modDirVersion = baseKernel.modDirVersion;
  # TODO? disable modules
  # linux-firecracker has no modules (?)

  allowImportFromDerivation = true;
}
