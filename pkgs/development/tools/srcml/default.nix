{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  cmake,
  libarchive,
  libxml2,
  libxslt,
  curl,
  boost,
  antlr2,
  ctpl,
}:

stdenv.mkDerivation rec {
  pname = "srcml";
  # version = "1.0.0"; # 2020-01-27
  version = "unstable-2024-04-28";

  src = fetchFromGitHub {
    owner = "srcML";
    repo = "srcML";
    # rev = "v${version}";
    rev = "26898eadbf47d66257184a1e14f29ef9a5d07969";
    hash = "sha256-xdz5BKMjImsS6jMvtaAaJyb7bSxwnsLdp0DQhk0ipns=";
  };

  patches = [
    # fix: error: 'transform' is not a member of 'std'
    # https://github.com/srcML/srcML/pull/1829
    (fetchurl {
      url = "https://github.com/srcML/srcML/pull/1829/commits/3a040d745f68cff4956a62a1bac3b020a5136ca6.patch";
      hash = "sha256-sxkxu/YgAAIsPhgpstO9gJcARfkR+A664U2jJBZU72E=";
    })
    # https://github.com/srcML/srcML/issues/2220
    ./fix-invalid-user-defined-conversion.patch
    # https://github.com/srcML/srcML/issues/2221
    ./fix-no-match-for-operator.patch
  ];

  # src/client/CMakeLists.txt
  src_CLI11_hpp = fetchurl {
    url = "https://github.com/CLIUtils/CLI11/releases/download/v1.8.0/CLI11.hpp";
    hash = "sha256-LftPpRcWVsob+73e5RMbj92xuDiE2jBkO/0hf1fpHwY=";
  };

  # src/client/CMakeLists.txt
  src_ctpl_stl_h = fetchurl {
    url = "https://raw.githubusercontent.com/vit-vit/CTPL/ctpl_v.0.0.2/ctpl_stl.h";
    hash = "sha256-vzb9zt8ngSNPVB1BFn3qSQdYMjSU40zs8KqJGdjOv6g=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace \
        "add_subdirectory(package)" \
        "# add_subdirectory(package)"

    substituteInPlace src/libsrcml/CMakeLists.txt \
      --replace \
        "COMMAND /usr/bin/strip" \
        "COMMAND strip"

    # src/client/CMakeLists.txt
    CMAKE_EXTERNAL_SOURCE_DIR=build/external
    mkdir -p $CMAKE_EXTERNAL_SOURCE_DIR
    cp ${src_CLI11_hpp} $CMAKE_EXTERNAL_SOURCE_DIR/CLI11.hpp
    cp ${src_ctpl_stl_h} $CMAKE_EXTERNAL_SOURCE_DIR/ctpl_stl.h
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libarchive
    libxml2
    libxslt
    curl
    boost
    antlr2
  ];

  meta = {
    description = "SrcML Toolkit";
    homepage = "https://github.com/srcML/srcML";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "srcml";
    platforms = lib.platforms.all;
  };
}
