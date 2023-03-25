/*
  TODO
  https://github.com/emmanuelrosa/erosanix/blob/491f24b47ed8bcbfeb0011374fd8829fa45438c5/pkgs/amazon-kindle/default.nix#L21
*/

{ pkgs
, lib
, stdenv
, wine
, p7zip
, callPackage
, version ? "1.17.44170"
}:

let
  versions = import ./versions.nix;
in

stdenv.mkDerivation {
  pname = "kindle";
  inherit version;
  src = versions.${version}.src;

  propagatedBuildInputs = [ wine ];
  nativeBuildInputs = [ p7zip ];

  phases = "buildPhase";

  # TODO check if working with read-only bin folder

  buildPhase = ''
    mkdir -p $out/opt/kindle
    cd $out/opt/kindle
    7z x -y $src
    # -> Kindle.exe
    mkdir $out/bin
    cat >$out/bin/kindle <<EOF
    #! /bin/sh
    export PATH=$PATH:${wine}/bin
    wine $out/opt/kindle/Kindle.exe "\$@"
    EOF
    chmod +x $out/bin/kindle
  '';

  meta = with lib; {
    description = "Amazon ebook reader";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
