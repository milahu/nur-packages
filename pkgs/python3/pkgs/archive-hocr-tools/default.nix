{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "archive-hocr-tools";
  version = "1.1.67";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "archive-hocr-tools";
    rev = version;
    hash = "sha256-ZHooJSF9qilF4pdz5I9rIAfP/LRaQsSKqNkinXuA1k4=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "hocr" ];

  meta = with lib; {
    description = "Efficient hOCR tooling";
    homepage = "https://github.com/internetarchive/archive-hocr-tools";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
  };
}
