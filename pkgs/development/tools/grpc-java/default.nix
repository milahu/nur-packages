# not tested

{ lib
, gradle2nix
, fetchFromGitHub
, protobuf
}:

gradle2nix.buildGradlePackage rec {
  pname = "grpc-java";
  version = "1.65.0";

  src = fetchFromGitHub {
    owner = "grpc";
    repo = "grpc-java";
    rev = "v${version}";
    hash = "sha256-lArVIn4Jfq/Ltfs8fl64VoOkUmVTwS3//9PU41Xb+LY=";
  };

  # 276 KByte
  # echo skipAndroid=true >> gradle.properties; gradle2nix
  lockFile = ./gradle.lock;

  # fix: C++ versions less than C++14 are not supported.
  CXXFLAGS = [ "-std=c++17" ];

  gradleBuildFlags = [
    #"--debug"

    # FIXME Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0.
    # https://github.com/haveno-dex/haveno/issues/1117
    #"--warning-mode" "all"

    # based on Makefile
    "build"
  ];

  gradleInstallFlags = [
    "installDist"
  ];

  nativeBuildInputs = [
    protobuf
  ];

  preBuild = ''
    echo skipAndroid=true >> gradle.properties
  '';

  meta = with lib; {
    description = "The Java gRPC implementation. HTTP/2 based RPC";
    homepage = "https://github.com/grpc/grpc-java";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "protoc-gen-grpc-java";
    platforms = platforms.all;
  };
}
