{ lib
, stdenvNoCC
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation rec {
  pname = "kaitai-struct-formats";
  version = "unstable-2023-03-28";

  src = fetchFromGitHub {
    owner = "kaitai-io";
    repo = "kaitai_struct_formats";
    rev = "5edcbc59ee300e0e60dad044cd1ec6b1eb298a74";
    hash = "sha256-i9VJSHmEm7ueExMOm5WKQr3995iZCBJ5piN1dJQGWa4=";
  };

  buildPhase = ''
    cp -r $src $out
  '';

  meta = with lib; {
    description = "Kaitai Struct: library of binary file formats (.ksy)";
    homepage = "https://github.com/kaitai-io/kaitai_struct_formats";
    # This repository contains work of many individuals.
    # Each .ksy is licensed separately:
    # please see meta/license tag and comments in every .ksy file for permissions.
    # Kaitai team claims no copyright over other people's contributions.
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
