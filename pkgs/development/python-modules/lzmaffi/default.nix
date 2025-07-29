/*
FIXME build error with xz-5.8.1

xz = /nix/store/ikfwx7kbwz9zr7fziiac7f57jgbh3bnv-xz-5.8.1-bin

Running phase: buildPhase
Executing pypaBuildPhase
Creating a wheel...
pypa build flags: --no-isolation --outdir dist/ --wheel
* Getting build dependencies for wheel...
This is lzmaffi version 0.0.3
lzmaffi/__pycache__/_cffi__x2ba174exbb7e6df9.c: In function ‘_cffi_check__lzma_stream’:
lzmaffi/__pycache__/_cffi__x2ba174exbb7e6df9.c:472:29: error: initialization of ‘lzma_allocator **’ from incompatible pointer type ‘const lzma_allocator **’ []
  472 |   { lzma_allocator * *tmp = &p->allocator; (void)tmp; }
      |                             ^
*/

{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  cffi,
  xz,
}:

buildPythonPackage rec {
  pname = "lzmaffi";
  # version = "0.0.3"; # 2013-03-18
  version = "unstable-2017-11-25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "r3m0t";
    repo = "backports.lzma";
    # rev = "v${version}";
    rev = "01f1a8571bae4ea977d3b2e3b4d244545c83523a";
    hash = "sha256-M/aPiHxhYzP0wK96f6zV5s1MG7PlIATCzJof03I/32I=";
  };

  /*
  preUnpack = ''
    echo xz = ${xz}
    exit 1
  '';
  */

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    cffi
    xz # lzma.h
  ];

  pythonImportsCheck = [
    "lzmaffi"
  ];

  meta = {
    description = "Backport of Python 3.3's standard library module lzma for LZMA/XY compressed files";
    homepage = "https://github.com/r3m0t/backports.lzma";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
  };
}
