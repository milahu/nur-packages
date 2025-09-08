{
  lib,
  fetchFromGitHub,
  expat,
}:

{
  name = "dav";
  src = fetchFromGitHub {
    name = "dav";
    owner = "arut";
    repo = "nginx-dav-ext-module";
    rev = "v3.0.0";
    sha256 = "000dm5zk0m1hm1iq60aff5r6y8xmqd7djrwhgnz9ig01xyhnjv9w";
  };

  inputs = [ expat ];

  meta = with lib; {
    description = "WebDAV PROPFIND,OPTIONS,LOCK,UNLOCK support";
    homepage = "https://github.com/arut/nginx-dav-ext-module";
    license = with licenses; [ bsd2 ];
    maintainers = [ ];
  };
}
