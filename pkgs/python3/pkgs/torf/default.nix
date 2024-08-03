{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, flatbencode
, coverage
, flake8
, isort
, pytest
, pytest-cov
, pytest-httpserver
, pytest-mock
, pytest-xdist
, ruff
, tox
}:

buildPythonPackage rec {
  pname = "torf";
  version = "4.2.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rndusr";
    repo = "torf";
    rev = "v${version}";
    hash = "sha256-xc/jObrGmiBQG6gl/G/ht+3iPf47LN5n3u7TRbMzRp4=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    flatbencode
  ];

  passthru.optional-dependencies = {
    dev = [
      coverage
      flake8
      isort
      pytest
      pytest-cov
      pytest-httpserver
      pytest-mock
      pytest-xdist
      ruff
      tox
    ];
  };

  pythonImportsCheck = [ "torf" ];

  meta = with lib; {
    description = "Python module to create, parse and edit torrent files and magnet links";
    homepage = "https://github.com/rndusr/torf";
    changelog = "https://github.com/rndusr/torf/blob/${src.rev}/CHANGELOG";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
