{ lib
, stdenv
, fetchFromGitHub
, cmake
, zycore
, python3
}:

stdenv.mkDerivation rec {
  pname = "zydis";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "zyantific";
    repo = "zydis";
    rev = "v${version}";
    hash = "sha256-akusu0T7q5RX4KGtjRqqOFpW5i9Bd1L4RVZt8Rg3PJY=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    zycore
    python3
  ];

  meta = with lib; {
    description = "Fast and lightweight x86/x86-64 disassembler and code generation library";
    homepage = "https://github.com/zyantific/zydis";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "zydis";
    platforms = platforms.all;
  };
}
