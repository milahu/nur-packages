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
, runCommand
, fetchurl
}:

let
  baseKernel = linuxKernel.packageAliases.linux_latest.kernel;

  # https://github.com/firecracker-microvm/firecracker/blob/main/resources/microvm-kernel-x86_64.config
  configfile-rev = "9b03e30a92c48be7fc061a46571e99862eaa1fd8";
  configfile-sha256 = "AEbQtRD7cWWJIzynEorT35wrfZrHnbSJ8a0wkC8wliE=";

  configfile-src = fetchurl {
    url = "https://github.com/firecracker-microvm/firecracker/raw/${configfile-rev}/resources/microvm-kernel-x86_64.config";
    sha256 = configfile-sha256;
  };

  # FIXME? replace variable $UNAME_RELEASE: CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
  # CONFIG_IKCONFIG: expose /proc/config.gz
  configfile = (runCommand "linux-firecracker.config" {} ''
    cp -v ${configfile-src} $out
    sed -i 's/# CONFIG_IKCONFIG is not set/CONFIG_IKCONFIG=y/' $out
  '').outPath;
in

linuxManualConfig rec {
  version = "${baseKernel.version}-firecracker";
  inherit stdenv lib configfile;
  inherit (baseKernel) src kernelPatches modDirVersion;
  # TODO? disable modules (modDirVersion, etc). linux-firecracker has no modules (?)
  allowImportFromDerivation = true;
}
