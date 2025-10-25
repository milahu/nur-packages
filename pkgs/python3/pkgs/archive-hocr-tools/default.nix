{ lib
, python3
, fetchFromGitHub
, buildPythonApplication
, setuptools
, wheel
, ebooklib
, pillow
, python-fontconfig
, tqdm
, psutil
}:

buildPythonApplication rec {
  pname = "archive-hocr-tools";
  version = "1.1.67-e4aaaa3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "archive-hocr-tools";
    # rev = version;
    # https://github.com/internetarchive/archive-hocr-tools/pull/23
    rev = "e4aaaa3115464522bf95b73f2f3d64bbdc9bbedc";
    hash = "sha256-ytf0LxKJBOsl9pY/PbJMkutkbMqQLR9mbNOtqYP0Iwo=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    ebooklib
    pillow
    python-fontconfig
    tqdm
    psutil
  ];

  pythonImportsCheck = [ "hocr" ];

  meta = with lib; {
    description = "Efficient hOCR tooling";
    homepage = "https://github.com/internetarchive/archive-hocr-tools";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
  };
}
