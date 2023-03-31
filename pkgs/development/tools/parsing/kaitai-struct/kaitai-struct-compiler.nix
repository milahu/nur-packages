{ lib
, stdenv
, fetchFromGitHub
, unzip
, jre
, makeWrapper
, kaitai-struct-formats
}:

stdenv.mkDerivation rec {
  pname = "kaitai-struct-compiler";
  version = "0.10";

  src = builtins.fetchurl {
    url = "https://github.com/kaitai-io/kaitai_struct_compiler/releases/download/0.10/kaitai-struct-compiler-0.10.zip";
    sha256 = "sha256:0syiamp68ad5abb02dc4n81wlignjmqjxnhgd2sayn6h8v6dc49x";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  buildPhase = ''
    mkdir $out
    cp -r bin lib $out
    wrapProgram $out/bin/kaitai-struct-compiler \
      --set JAVA_HOME ${jre} \
      --set KSPATH ${kaitai-struct-formats}
  '';

  meta = with lib; {
    description = "Kaitai Struct compiler for codegen from ksy files";
    homepage = "https://github.com/kaitai-io/kaitai_struct_compiler";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
