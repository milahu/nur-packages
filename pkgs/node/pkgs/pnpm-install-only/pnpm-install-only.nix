{ lib
, pkgs
, fetchFromGitHub
, callPackage
#, python3
, git
, npmlock2nix
}:

npmlock2nix.v2.build rec {
  pname = "pnpm-install-only";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "pnpm-install-only";
    /*
    rev = version;
    hash = "sha256-g5PAHHpYYnNhgwyFdhUsSuBXqZHi1Q6zhWXwZd1iAG8=";
    */
    rev = "f90260de0cd3d078eefae669231de26e68e4a35b";
    hash = "sha256-54WC6+/jG0fdVaKMOIU3A2GR0feeuPd7AYmaEflpZcM=";
  };

  # dont run "npm run build"
  buildCommands = [ ];

  # FIXME
  #  mv -v $out/bin/redis-commander.js $out/bin/redis-commander
  installPhase = ''
    mkdir -p $out/opt
    cp -r . $out/opt/$pname
    mkdir $out/bin
    ln -sr $out/opt/$pname/src/index.js $out/bin/$pname
  '';

  #node_modules_mode = "copy";

  node_modules_attrs = {
    preBuild = ''
      echo "node_modules preBuild"
      set -x

      # debug
      set -x
      command -v npm
    '';

    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;

    #unpackNodePackages = true; # TODO implement

    buildInputs = [
      #python3 # for node-gyp

      git # TODO remove
    ];

    githubSourceHashMap = {
      milahu.nodejs-lockfile-parser.b4ffaffa0872c4e40f38319b4ae76246de5cc4b3 = "sha256-C1BU5ei59htkc28b7l0eTMYrFIch2J1bberhuUGJTHU=";
    };

  };

  meta = with lib; {
    description = "Minimal implementation of 'pnpm install'";
    homepage = "https://github.com/milahu/pnpm-install-only";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
