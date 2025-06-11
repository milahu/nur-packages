/*
the source was removed from github
https://web.archive.org/web/20240918163105/https://github.com/uktrade/stream-zip

reconstructed source with git tags:
https://github.com/milahu/stream-zip

alternatives:
https://github.com/sandes/zipfly # 2025, 500 stars
https://github.com/arjan-s/python-zipstream # 2023, 50 stars
https://github.com/kbbdy/zipstream # 2020, 40 stars
https://github.com/pR0Ps/zipstream-ng # 30 stars
https://github.com/DoctorJohn/aiohttp-zip-response # 1 stars
https://github.com/baldhumanity/py_stream_zip # 0 stars
*/

{ lib
, python3
, fetchFromGitHub
, fetchPypi
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "stream-zip";
  version = "0.0.83";
  pyproject = true;

  src =
  if true then
  fetchurl {
    url = "https://files.pythonhosted.org/packages/08/8a/0674a98c1d3d8edf1461b92474ed9cfe19298a297aab9a8ccd9ae1f15b07/stream_zip-0.0.83.tar.gz";
    hash = "sha256-h9dV8M5D38awrlVbcz8WLHbi6vzzx4BdP1kelmsxZxY=";
  }
  else
  if true then
  # http 404 ?!
  fetchPypi {
    inherit pname version;
    hash = "";
  }
  else
  fetchFromGitHub {
    owner = "uktrade";
    repo = "stream-zip";
    rev = "v${version}";
    hash = "sha256-zcYfpojAy0ZfJHuvYtsEr9SSpTc+tOH8gTKI9Fd4oHg=";
  };

  nativeBuildInputs = [
    python3.pkgs.hatchling
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pycryptodome
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    ci = [
      coverage
      pycryptodome
      pytest
      pytest-cov
      pyzipper
      stream-unzip
    ];
    dev = [
      coverage
      pytest
      pytest-cov
      pyzipper
      stream-unzip
    ];
  };

  pythonImportsCheck = [ "stream_zip" ];

  meta = with lib; {
    description = "Python function to construct a ZIP archive on the fly";
    homepage = "https://pypi.org/project/stream-zip/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
