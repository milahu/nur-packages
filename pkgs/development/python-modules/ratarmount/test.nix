# run tests outside of the nix-build sandbox

# based on https://github.com/mxmlnkn/ratarmount/blob/master/.github/workflows/tests.yml

{
  lib,
  stdenv,
  ratarmountcore,
  ratarmount,
  # fetchgit,
  makeWrapper,
  makePythonPath,
  # pytestCheckHook,
  pytest,
  moreutils,
  sqlite, # sqlar?
  coreutils,
  python,
  gnutar,
  pixz,
  bzip2,
  gzip,
  procps,
  gnugrep,
  pkgs,
  diffutils,
  findutils,
  gnused,
  bash,
}:

stdenv.mkDerivation rec {
  pname = "ratarmount-test";

  inherit (ratarmount) version src;

  nativeBuildInputs = [
    makeWrapper
    moreutils # sponge
  ];

  # WONTFIX? many tests fail
  # https://discourse.nixos.org/t/using-fuse-inside-nix-derivation/8534
  /*
  nativeCheckInputs = [
    pytestCheckHook
    zstandard
    # tests/test_BlockParallelReaders.py
    # subprocess.run(['zstd'
    zstd
    # TODO verify
    lrzip
    lzop
  ];
  */

  # TODO cleanup. use pytest?
  postInstall =
  if false then
  (
  let
    nativeTestInputs = [
    ];
    pythonTestInputs = ratarmountcore.propagatedBuildInputs;
  in
  ''
    # cp -r tests $out
    # cp -r . $out
    cp -r .. $out
    # for f in $out/test_*.py; do
    # for f in $out/tests/test_*.py; do
    for f in $out/core/tests/test_*.py; do
      {
        echo '#!${pytest}/bin/pytest'
        echo 'import sys'
        echo 'sys.path += "'${makePythonPath pythonTestInputs}:$(toPythonPath $out)'".split(":")'
        # echo 'sys.path += "'${makePythonPath pythonTestInputs}'".split(":")'
        echo 'import os'
        echo 'os.environ["PATH"] += "${lib.makeBinPath nativeTestInputs}"'
        cat "$f" | grep -v -F "sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))"
        # cat "$f"
      } | sponge "$f"
      chmod +x "$f"
    done
    if false; then
    cat >$out/test.sh <<'EOF'
    #!/usr/bin/env bash
    cd "$(dirname "$0")"
    for f in test_*.py; do
      echo "$f"
      ./"$f"
    done
    EOF
    chmod +x $out/test.sh
    fi
    # no. we also have to run this on runtime, not in the nix-build sandbox
    if false; then
    echo "generating test files"
    bash $out/tests/create-tests.sh
    else
    chmod -R +w $out/tests/
    # sed -i '1 i\#!/usr/bin/env bash' $out/tests/create-tests.sh
    # sed -i '1 i\#!/usr/bin/env bash\nset -eux' $out/tests/create-tests.sh
    sed -i '1 i\#!/usr/bin/env bash\nset -x' $out/tests/create-tests.sh
    chmod +x $out/tests/create-tests.sh
    fi
  ''
  )
  else
  (
  let
    nativeTestInputs = [
      coreutils # dd
      python
      pytest
      gnutar
      # sqlite
      pixz
      bzip2
      gzip
      procps # pkill
      gnugrep
      pkgs.zstd
      diffutils
      findutils
      # TODO upstream: these commands are not checked: for tool in dd zstd stat ...
      pkgs.attr # setfattr
      gnused
      pkgs.fuse # fusermount
      bash
    ];
    pythonTestInputs = ratarmountcore.propagatedBuildInputs;
  in
  ''
    mkdir -p $out/bin
    cat >$out/bin/ratarmount-test <<EOF
    #!/usr/bin/env bash
    set -e
    # set -u # RATARMOUNT_CMD unbound
    set -x
    export PYTHONPATH=${makePythonPath pythonTestInputs}:$(toPythonPath $out)
    # TODO more
    export PATH=${lib.makeBinPath nativeTestInputs}
    export LANG=C
    tempdir=\$(mktemp -d --tmpdir ratarmount-test.XXXXXXXXXX)
    echo "using tempdir \$tempdir"
    cd \$tempdir
    cp -r --no-preserve=owner ${src} ratarmount
    chmod -R +w ratarmount
    cd ratarmount
    RATARMOUNT_CMD=${ratarmount}/bin/ratarmount
    CI=1 # dont run tests/run-style-checkers.sh
    echo "calling tests/runtests.sh ..."
    # FIXME pkill: killing pid 1370 failed: Operation not permitted
    . tests/runtests.sh
    echo "calling tests/runtests.sh done"
    echo "keeping tempdir \$tempdir"
    EOF
    chmod +x $out/bin/ratarmount-test

    # TODO also run: python3 tests/tests.py
  ''
  );
}
