{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "mini-racer";
  version = "0.14.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bpcreech";
    repo = "PyMiniRacer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oayWmjIo5CTKXGa1RtGK8nxzOEfwrHb6i67eXpI5iM0=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "mini_racer"
  ];

  meta = {
    description = "PyMiniRacer is a V8 bridge in Python";
    homepage = "https://github.com/bpcreech/PyMiniRacer";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
  };
})
