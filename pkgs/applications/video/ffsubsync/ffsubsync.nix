{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "ffsubsync";
  version = "0.4.22";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "smacke";
    repo = "ffsubsync";
    rev = version;
    hash = "sha256-Tlnw098ndO32GsRq3SQ0GpNdZl9WEPBsDOHZYl1BI8E=";
  };

  buildInputs = with python3.pkgs; [
    setuptools
  ];

  postPatch = ''
    sed -i 's/==/>=/g' requirements.txt
  '';

  propagatedBuildInputs = with python3.pkgs; [
    auditok
    cchardet
    chardet
    charset-normalizer
    ffmpeg-python
    future
    numpy
    pysubs2
    rich
    six
    srt
    tqdm
    typing-extensions
    webrtcvad
    #webrtcvad-wheels # binary release
  ];

  pythonImportsCheck = [ "ffsubsync" ];

  meta = with lib; {
    description = "Automagically synchronize subtitles with video";
    homepage = "https://github.com/smacke/ffsubsync";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
