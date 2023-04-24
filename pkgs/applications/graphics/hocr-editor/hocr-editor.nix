# TODO fix build on windows

{ lib
, buildDotnetPackage
, fetchFromGitHub
, dotnetPackages
, pkg-config
, msbuild
, dotnet-sdk
, tesseract
}:

let
  arrayToShell = (a: toString (map (lib.escape (lib.stringToCharacters "\\ ';$`()|<>\t") ) a));
in

buildDotnetPackage rec {
  pname = "hocr-editor";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "GeReV";
    repo = "HocrEditor";
    rev = "v${version}";
    hash = "sha256-UMp3iI86PI/4//lrp/xOWLc5q+Exta049UbNUAnYJfg=";
  };

  msBuildFiles = [
    "HocrEditor/HocrEditor.csproj"
    "HocrEditor.Tesseract/HocrEditor.Tesseract.csproj"
  ];

  nativeBuildInputs = [
    msbuild
    pkg-config
    #dotnet-sdk
  ];

  buildInputs = [
  ];

  propagatedBuildInputs = [
    tesseract
  ];

  checkInputs = [
    dotnetPackages.NUnit
    dotnetPackages.NUnitRunners
  ];

  msBuildFlags = [
    "/p:Configuration=Release"
  ];

  # based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/dotnet/build-dotnet-package/default.nix
  buildPhase = ''
    runHook preBuild

    echo Building dotNET packages...

    # Probably needs to be moved to fsharp
    if pkg-config FSharp.Core
    then
      export FSharpTargetsPath="$(dirname $(pkg-config FSharp.Core --variable=Libraries))/Microsoft.FSharp.Targets"
    fi

    ran=""
    for msBuildFile in ${arrayToShell msBuildFiles} ''${msBuildFilesExtra}
    do
      ran="yes"
      msbuild ${arrayToShell msBuildFlags} ''${msBuildFlagsArray} $msBuildFile
    done

    [ -z "$ran" ] && msbuild ${arrayToShell msBuildFlags} ''${msBuildFlagsArray}

    runHook postBuild
  '';

  meta = with lib; {
    description = "edit HOCR files from tesseract OCR";
    homepage = "https://github.com/GeReV/HocrEditor";
    platforms = with platforms; [ windows ];
    license = with licenses; [ lgpl3 ];
    maintainers = with maintainers; [ ];
  };
}
