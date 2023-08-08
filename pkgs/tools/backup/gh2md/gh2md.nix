{ lib
, python3Packages
, fetchPypi
}:

python3Packages.buildPythonApplication rec {
  pname = "gh2md";
  version = "2.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-vdbYPg9Lr0PN3bInFryhggvs8bsMOJVepRT+n8gPSuE=";
  };

  propagatedBuildInputs = with python3Packages; [ six requests python-dateutil ];

  # uses network
  doCheck = false;

  pythonImportsCheck = [ "gh2md" ];

  meta = with lib; {
    description = "Export Github repository issues to markdown files";
    homepage = "https://github.com/mattduck/gh2md";
    license = licenses.mit;
    maintainers = with maintainers; [ artturin ];
  };
}
