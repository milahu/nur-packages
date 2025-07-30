# based on https://github.com/milahu/nur-packages/blob/master/pkgs/development/tools/gumtree/default.nix
# based on https://github.com/milahu/nur-packages/blob/master/pkgs/applications/blockchains/haveno/default.nix

{
  lib,
  callPackage,
  fetchFromGitHub,
  gradle2nix,
  # protobuf_31,
  makeWrapper,
  jdk,
}:

let
  # TODO upstream: this belongs to gradle2nix.mkOverride
  mkOverride = callPackage ./gradle2nix-mk-override.nix { };

  # no. protoc is not used by the gradle build
  # protobuf = protobuf_31;
  /*
  # no. building protobuf from source is 1000x slower
  # than fixing the com.google.protobuf:protoc jar file
  # no. protobuf_31 already is version 4.31.1
  protobuf = protobuf_31.overrideAttrs (o: rec {
    version = "4.31.1";
    # https://github.com/protocolbuffers/protobuf
    src = fetchFromGitHub {
      owner = "protocolbuffers";
      repo = "protobuf";
      rev = "v${version}";
      hash = "sha256-E8q8XupOXoCFpXyGNHArfBmVm6ebfDgaJlJyvMqpveU=";
    };
    # fix:
    # Did not find version 4.31.1 in the output of the command protoc --version
    # libprotoc 31.1
    doInstallCheck = false;
  });
  */
in

gradle2nix.buildGradlePackage rec {
  pname = "xtdb";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "xtdb";
    repo = "xtdb";
    rev = "v${version}";
    hash = "sha256-MmgJCKxnX2cYX3zJFM82Wpagb2xdlScYP480wlAQ+50=";
  };

  # https://github.com/xtdb/xtdb/blob/v2.0.0/.gitmodules
  # https://github.com/xtdb/xtdb/tree/v2.0.0/modules/datasets/lib
  src-tsbs = fetchFromGitHub {
    owner = "timescale";
    repo = "tsbs";
    rev = "37fced794d56d3b33fbf40e55a0f1d3d78d05802";
    hash = "sha256-3awK9bpmh8izoz4CbLONAbDPRQsmE/OMeGB9uZihryA=";
  };

  # alternative to "fetchSubmodules = true"
  postUnpack = ''
    pushd $sourceRoot
    rmdir modules/datasets/lib/tsbs
    ln -s ${src-tsbs} modules/datasets/lib/tsbs
    popd
  '';

  # lockfile generated with
  /*
    nix-shell -p jre nur.repos.milahu.gradle2nix git git-lfs
    git clone --depth=1 https://github.com/xtdb/xtdb -b v2.0.0
    cd xtdb
    gradle2nix
  */
  lockFile = ./gradle.lock;

  nativeBuildInputs = [
    # no. protoc is not used by the gradle build
    # protobuf
    makeWrapper
  ];

  gradleBuildFlags = [
    /*
    # There were failing tests. See the report at: file:///build/source/http-server/build/reports/tests/test/index.html
    "--exclude-task=:xtdb-http-server:test"
    "--exclude-task=:modules:xtdb-flight-sql:test"
    "--exclude-task=:modules:xtdb-kafka-connect:test"
    "--exclude-task=:xtdb-core:test"
    "--exclude-task=:test"
    # FIXME this is not implemented in gradle
    # https://github.com/gradle/gradle/issues/34433
    # "--exclude-task=*:test"
    "build"
    */

    # "--scan" # debug # no. this creates new errors

    # "--stacktrace" # debug

    # FIXME Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0.
    # "--warning-mode" "all" # debug

    # build all default targets
    # "build"

    # based on docker/bin/build-standalone-image.sh
    # docker/standalone/build.gradle.kts
    ":docker:standalone:shadowJar"

    # TODO build more shadowJar targets?
    /*
    $ find xtdb/ -name 'build.gradle*' | xargs grep -Hn shadowJar 
    xtdb/cloud-benchmark/aws/build.gradle.kts:23:tasks.shadowJar {
    xtdb/cloud-benchmark/azure/build.gradle.kts:23:tasks.shadowJar {
    xtdb/cloud-benchmark/local/build.gradle.kts:19:tasks.shadowJar {
    xtdb/cloud-benchmark/google-cloud/build.gradle.kts:23:tasks.shadowJar {
    xtdb/modules/bench/build.gradle.kts:32:tasks.shadowJar {
    xtdb/modules/kafka-connect/build.gradle.kts:44:tasks.shadowJar {
    xtdb/buildSrc/build.gradle.kts:20:tasks.shadowJar {
    xtdb/monitoring/docker-image/build.gradle.kts:21:tasks.shadowJar {
    xtdb/docker/aws/build.gradle.kts:33:tasks.shadowJar {
    xtdb/docker/azure/build.gradle.kts:33:tasks.shadowJar {
    xtdb/docker/standalone/build.gradle.kts:31:tasks.shadowJar {
    xtdb/docker/google-cloud/build.gradle.kts:33:tasks.shadowJar {
    */
    # ":modules:kafka-connect:shadowJar"
    # ":buildSrc:shadowJar"
    # ":monitoring:docker-image:shadowJar"
    # ":docker:aws:shadowJar"
  ];

  # FIXME build.gradle.kts has no installDist target
  # error: builder failed to produce output path for output 'out'
  # https://github.com/xtdb/xtdb/issues/4637
  /*
  gradleInstallFlags = [
    "installDist"
  ];
  */

  installPhase =
  if false then ''
    # debug: install all files
    mkdir -p $out/opt
    cp -r . $out/opt/xtdb
    # remove broken symlinks
    # fix: ERROR: noBrokenSymlinks: the symlink x points to a missing target y
    find $out -xtype l -delete
    mkdir -p $out/bin
    # TODO gradle2nix should set offlineRepo
    offlineRepo=$(grep -F -m1 "repo.url 'file:" $gradleInitScript | sed -E "s|.*'file:(.*)'.*|\1|")
    echo "offlineRepo: $offlineRepo"
    find $out -path '*/build/scripts/*' | grep -v '\.bat$' |
    while read script; do
      echo "script: $script"
      # patch classpath in script
      classpath=$(find $offlineRepo $out -false $(printf ' -or -name %s' $(grep -m1 ^CLASSPATH= "$script" | tr : $'\n' | sed 's|\$APP_HOME/lib/||')) | tr $'\n' :)
      sed -i "s|^CLASSPATH=.*|CLASSPATH=$classpath|" "$script"
      n=$(echo "$script" | sed -E 's|.*/(xtdb/.*)/build/scripts/.*|\1|' | tr / -)
      ln -svr "$script" $out/bin/$n
    done
  ''
  else
  # based on https://github.com/xtdb/xtdb/blob/v2.0.0/docker/standalone/Dockerfile
  ''
    mkdir -p $out/lib
    cp docker/standalone/build/libs/xtdb-standalone.jar $out/lib
    mkdir -p $out/bin
    cat >$out/bin/xtdb <<EOF
    exec ${jdk}/bin/java \
      -cp $out/lib/xtdb-standalone.jar \
      -Dclojure.main.report=stderr \
      --add-opens=java.base/java.nio=ALL-UNNAMED \
      -Dio.netty.tryReflectionSetAccessible=true \
      clojure.main -m xtdb.main
    EOF
    chmod +x $out/bin/xtdb
  '';

  # TODO keep names in sync with gradle.lock
  # or use overridesGlob
  # https://github.com/tadfisher/gradle2nix/pull/62#issuecomment-2820420531
  overrides = {
    # fix: Cannot set protoc-4.31.1-linux-x86_64.exe as executable
    "com.google.protobuf:protoc:4.31.1" = {
      "protoc-4.31.1-linux-x86_64.exe" = src: mkOverride src { };
    };
  };

  meta = {
    description = "An immutable SQL database for application development, time-travel reporting and data compliance. Developed by @juxt";
    homepage = "https://github.com/xtdb/xtdb";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "xtdb";
    platforms = lib.platforms.all;
  };
}
