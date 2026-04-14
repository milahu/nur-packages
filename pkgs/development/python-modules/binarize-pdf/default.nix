{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # pytestCheckHook,
  setuptools,
  pdf2image,
  pymupdf,
  opencv-python,
  numpy,
  pillow,
  tqdm,
  doxapy,
}:

buildPythonPackage rec {
  pname = "binarize-pdf";
  version = "0.1.0-6360efe";

  src = fetchFromGitHub {
    owner = "rahimnathwani";
    repo = "binarize-pdf";
    # https://github.com/rahimnathwani/binarize-pdf/pull/2
    rev = "6360efef9d27a62c5de061384e1467ef20c15913";
    hash = "sha256-FVUp0NSdhelWC3x1ESQ1DeGkpiOcVa7C8Xy7DWR7GIY=";
  };

  pyproject = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pdf2image
    pymupdf
    opencv-python
    numpy
    pillow
    tqdm
    doxapy
  ];

  postInstall = ''
    mv -v $out/bin/binarize-pdf.py $out/bin/binarize-pdf
  '';

  meta = with lib; {
    description = "Convert PDF to black and white using adaptive thresholding";
    homepage = "https://github.com/rahimnathwani/binarize-pdf";
    # TODO add license
    # https://github.com/rahimnathwani/binarize-pdf/issues/1
    license = licenses.unfree;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "binarize-pdf";
    platforms = platforms.all;
  };
}
