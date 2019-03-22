{ stdenv, fetchFromGitHub, rustPlatform, cmake, pkgconfig, freetype, gtk3, wrapGAppsHook, xi-core }:

rustPlatform.buildRustPackage rec {
  name = "gxi-unstable-${version}";
  version = "2019-03-21";
  
  src = fetchFromGitHub {
    owner = "Cogitri";
    repo = "gxi";
    rev = "223db957ace2609cd2669e2a355021b0b9047136";
    sha256 = "02vk0qm4mvf6xibisrykaqmz10kh1i7zzfwhh4b3a98yj2zlfic1";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkgconfig freetype ];

  buildInputs = [
    gtk3
    wrapGAppsHook
  ];

  GXI_PLUGIN_DIR = "${placeholder "out"}/share/xi/plugins";

  hardeningDisable = [ "format" ]; # build error in gettext/gnulib??

  cargoSha256 = "00cggr0gxs0cs1v9mkpfr2x909wc4y16lblixa24ar1xb8h2axdl";

  postInstall = ''
    mkdir -p ${GXI_PLUGIN_DIR}
    ln -s ${xi-core.syntect} ${GXI_PLUGIN_DIR}/synctect
  '';

  meta = with stdenv.lib; {
    description = "GTK frontend for the xi text editor, written in rust";
    homepage = https://github.com/bvinc/gxi;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
