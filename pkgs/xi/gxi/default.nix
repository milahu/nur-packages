{ stdenv, fetchFromGitHub, rustPlatform, cmake, pkgconfig, freetype, gtk3, wrapGAppsHook, wrapXiFrontendHook }:

rustPlatform.buildRustPackage rec {
  name = "gxi-unstable-${version}";
  version = "2019-02-01";
  
  src = fetchFromGitHub {
    owner = "Cogitri";
    repo = "gxi";
    rev = "8c4cb673417f391d6ddc2b868ded2c5569ab0cd9";
    sha256 = "080d1knlcxzxzn30wqpwg1fy934z335w0jkvfpd9gvij8r0ir5ad";
  };

  nativeBuildInputs = [ cmake pkgconfig freetype ];

  buildInputs = [
    gtk3
    wrapGAppsHook
    wrapXiFrontendHook
  ];

  cargoSha256 = "0v72s58g0v69gpja8n0sxzpc821849p6q53pmyasbrnjhyh51nxw";

  postInstall = "wrapXiFrontend $out/bin/*";

  meta = with stdenv.lib; {
    description = "GTK frontend for the xi text editor, written in rust";
    homepage = https://github.com/bvinc/gxi;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
