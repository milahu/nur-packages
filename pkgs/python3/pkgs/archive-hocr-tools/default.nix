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
  version = "1.1.67-34ed639";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "archive-hocr-tools";
    # rev = version;
    # https://github.com/internetarchive/archive-hocr-tools/pull/23
    rev = "34ed6393dadd565b885b297f56450d374f76507d";
    hash = "sha256-5KfafBspwfAQatzZl52PXMD9rqCaHp8nczleZOcDBOo=";
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
