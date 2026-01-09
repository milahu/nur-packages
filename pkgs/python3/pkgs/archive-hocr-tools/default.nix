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
  version = "1.1.67-fe94f23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "archive-hocr-tools";
    # rev = version;
    # https://github.com/internetarchive/archive-hocr-tools/pull/23
    rev = "fe94f23eadbcca8b2112e199e3a73726a2a25854";
    hash = "sha256-t0koRiEPpVwdOxafwqHe05x1buLCwM52OSj1Syzm9Ug=";
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
