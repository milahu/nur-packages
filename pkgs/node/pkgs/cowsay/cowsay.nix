/*
fixme? can we just use old lockfiles?

npm WARN old lockfile The package-lock.json file was created with an old version of npm,
npm WARN old lockfile so supplemental metadata must be fetched from the registry.
npm WARN old lockfile This is a one-time fix-up, please be patient...
*/

{ lib
, pkgs
, fetchFromGitHub
, callPackage
, python3
, git
, npmlock2nix
}:

npmlock2nix.build rec {
#npmlock2nix.v2.build rec {
#npmlock2nix.granular-caching.build rec {
#npmlock2nix.v1.build rec { # ok

  pname = "cowsay";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "piuccio";
    repo = "cowsay";
    rev = "v${version}";
    hash = "sha256-TZ3EQGzVptNqK3cNrkLnyP1FzBd81XaszVucEnmBy4Y=";
  };

  buildCommands = [
    ''
      set -x
      #export HOME=$TMP
      #npm run build --verbose --debug
      npm run prepare --verbose --debug
      #npm run build-desktop --verbose --debug
      set +x
    ''
  ];

  # FIXME
  #  mv -v $out/bin/redis-commander.js $out/bin/redis-commander
  installPhase = ''
    mkdir -p $out/opt
    cp -r . $out/opt/cowsay
    mkdir -p $out/bin
    ln -sr $out/opt/cowsay/cli.js $out/bin/cowsay
  '';

  #node_modules_mode = "copy";

  node_modules_attrs = {

    # force rebuild of node_packages
    #  set -x
    /*
    preBuild = ''
      echo "node_modules preBuild"
      echo force rebuild...
      echo force rebuild...
    '';
    */

    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;
    unpackNodePackages = true; # TODO implement
    buildInputs = [
    ];
    githubSourceHashMap = {
      #dotcs.license-ls."746b0835939930871332a501cd18f362245143c5" = "sha256-kr/Pawz66e9ljFlKO2+PTA677cv7JSoJG4ntxG8qSII=";
    };
  };

  meta = with lib; {
    description = "cowsay is a configurable talking cow";
    homepage = "https://github.com/piuccio/cowsay";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ];
  };
}
