{
  lib,
  stdenv,
  boost,
  fetchFromGitHub,
  openssl,
  zlib,
}:

stdenv.mkDerivation {
  pname = "i2pd-tools";
  version = "2.56.0.8c95338";

  #tries to access the network during the tests, which fails

  src = fetchFromGitHub {
    owner = "PurpleI2P";
    repo = "i2pd-tools";
    rev = "8c953386b4823b1af0908098574329a25cb72348";
    hash = "sha256-SbSZWkrx/pl2HcRgaRcnUML6qgkvJBPzhbxyKKv5P64=";
    fetchSubmodules = true;
  };

  # fix: error: cannot convert 'std::__cxx11::basic_string<char>::iterator' to 'const char*'
  # https://github.com/PurpleI2P/i2pd-tools/issues/104
  postPatch = ''
    substituteInPlace i2pbase64.cpp \
      --replace-fail \
        "#include <cassert>" \
        "#include <cassert>"$'\n'"#include <algorithm>"
  '';

  buildInputs = [
    zlib
    openssl
    boost
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    for bin in \
        routerinfo keygen vain keyinfo regaddr \
        regaddr_3ld regaddralias x25519 famtool autoconf;
    do
      install -Dm755 $bin -t $out/bin
    done

    runHook postInstall
  '';

  meta = {
    description = "Toolsuite to work with keys and eepsites";
    homepage = "https://github.com/PurpleI2P/i2pd-tools";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ MulliganSecurity ];
    mainProgram = "i2pd-tools";
  };
}
