{ stdenv, fetchFromGitHub, rustPlatform, cmake, pkgconfig, freetype, gtk3, wrapGAppsHook, xi-core }:

rustPlatform.buildRustPackage rec {
  name = "gxi-unstable-${version}";
  version = "2019-02-18";
  
  src = fetchFromGitHub {
    owner = "Cogitri";
    repo = "gxi";
    rev = "edba6fd994dbc66649d1c24f8db8925ca025eb1f";
    sha256 = "076n3qacgpsrnnf2jqcnm5rabbh7w8a3877dirbgcm05q0p19bhb";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkgconfig freetype ];

  buildInputs = [
    gtk3
    wrapGAppsHook
  ];

  GXI_PLUGIN_DIR = "${placeholder "out"}/share/xi/plugins";

  hardeningDisable = [ "format" ]; # build error in gettext/gnulib??

  cargoSha256 = "1qfwdkjq09xs5vcjhzkp28jpamzds9h0sq366mifar40v4z5z10h";

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
