{ lib
, python3
, buildPythonApplication
, setuptools
, wheel
, argostranslate
, beautifulsoup4
, fetchFromGitHub
}:

buildPythonApplication rec {
  pname = "argos-translate-html";
  version = "unstable-2023-07-08";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "argosopentech";
    repo = "translate-html";
    rev = "d1bdce42901df22e40f29e42bc4fd5784e588ee5";
    hash = "sha256-QOhjmQsfdLBjijjTt0WTkgRespGHeQKd4NpPd3dRr8Y=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    argostranslate
    beautifulsoup4
  ];

  pythonImportsCheck = [ "translatehtml" ];

  # fix: PermissionError: [Errno 13] Permission denied: '/homeless-shelter'
  preBuild = ''
    export HOME=$TMP
  '';

  meta = with lib; {
    description = "Translate HTML using Argos Translate";
    homepage = "https://github.com/argosopentech/translate-html";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "translate-html";
  };
}
