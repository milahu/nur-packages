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
  version = "1.1.67-6ea6a9c";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "archive-hocr-tools";
    # rev = version;
    # https://github.com/internetarchive/archive-hocr-tools/pull/23
    rev = "f65b4d464027a78d077cf5987754662df07d15f0";
    hash = "sha256-N4KJb18UP3TNz98VRCWCPAUzXfstGGN4P+dMSRCtV7Y=";
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
