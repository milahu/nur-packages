{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "zycore-c";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "zyantific";
    repo = "zycore-c";
    rev = "v${version}";
    hash = "sha256-Kz51EIaw4RwrOKXhuDXAFieGF1mS+HL06gEuj+cVJmk=";
  };

  nativeBuildInputs = [
    cmake
  ];

  # TODO fix CMakeLists.txt
  postInstall = ''
    sed -i "s|\''${PACKAGE_PREFIX_DIR}/$out|$out|" $out/lib/cmake/zycore/zycore-config.cmake
  '';

  meta = with lib; {
    description = "Internal library providing platform independent types, macros and a fallback for environments without LibC";
    homepage = "https://github.com/zyantific/zycore-c";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "zycore-c";
    platforms = platforms.all;
  };
}
