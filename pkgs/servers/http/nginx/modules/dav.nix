{
  lib,
  mkNginxPlugin,
  fetchFromGitHub,
  expat,
}:

mkNginxPlugin rec {
  pname = "dav";
  version = "4.0.1";
  src = fetchFromGitHub {
    pname = "dav";
    owner = "mid1221213";
    repo = "nginx-dav-ext-module";
    rev = "v${version}";
    hash = "sha256-BMYRH/BNuq/TTWPWdQJpz/Mx64vNEN7SQ/Swu3by92A=";
  };

  inputs = [ expat ];

  meta = with lib; {
    description = "WebDAV PROPFIND,OPTIONS,LOCK,UNLOCK support";
    homepage = "https://github.com/mid1221213/nginx-dav-ext-module";
    license = with licenses; [ bsd2 ];
    maintainers = [ ];
  };
}
