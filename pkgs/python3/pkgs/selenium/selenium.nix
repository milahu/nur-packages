{ lib
, fetchFromGitHub
, fetchPypi
, buildPythonPackage
, certifi
, geckodriver
, pytestCheckHook
, pythonOlder
, trio
, trio-websocket
, urllib3
, pytest-trio
, nixosTests
, stdenv
, python
}:

buildPythonPackage rec {
  pname = "selenium";
  version = "4.14.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "SeleniumHQ";
    repo = "selenium";
    # check if there is a newer tag with or without -python suffix
    rev = "refs/tags/selenium-${version}";
    hash = "sha256-cTMCKfFLUlJDbTUQA3Z/pKCE1RQQRMb4K8hKKn9HqvU=";
  };

  # also add selenium.webdriver.common.devtools.* packages
  # fix: ModuleNotFoundError: No module named 'selenium.webdriver.common.devtools'

  src-pypi = fetchPypi {
    inherit pname version;
    hash = "sha256-DRSw2YQjZvOPtfj4Qs98BCvPoGKv/GoKhuTWNL3Q/lQ=";
  };

  # relax versions
  # fix: typing-extensions~=4.9 not satisfied by version 4.8.0
  # https://github.com/SeleniumHQ/selenium/blob/trunk/py/setup.py

  # also add selenium.webdriver.common.devtools.* packages
  # fix: ModuleNotFoundError: No module named 'selenium.webdriver.common.devtools'
  # https://github.com/milahu/nixpkgs/issues/20

  postUnpack = ''
    cd $sourceRoot/py
    echo unpacking selenium/webdriver/common/devtools from ${src-pypi}
    tar --strip-components=1 --wildcards -x -f ${src-pypi} 'selenium-*/selenium/webdriver/common/devtools'
    cd ../..
  '';

  postPatch = ''
    cd py
    sed -i 's/[~>]=.*"/"/' setup.py
    substituteInPlace setup.py \
      --replace \
        "    'packages': [" \
        "    'packages': find_namespace_packages(where='.'), '_packages': [" \
      --replace \
        "from setuptools import setup" \
        "from setuptools import setup, find_namespace_packages"
    cd ..
  '';

  preConfigure = ''
    cd py
  '';

  # FIXME _pytest.pathlib.ImportPathMismatchError
  doCheck = false;

  postInstall = ''
    DST_PREFIX=$out/lib/${python.libPrefix}/site-packages/selenium/webdriver/
    DST_REMOTE=$DST_PREFIX/remote/
    DST_FF=$DST_PREFIX/firefox
    cp ../rb/lib/selenium/webdriver/atoms/getAttribute.js $DST_REMOTE
    cp ../rb/lib/selenium/webdriver/atoms/isDisplayed.js $DST_REMOTE
    cp ../rb/lib/selenium/webdriver/atoms/findElements.js $DST_REMOTE
    cp ../javascript/cdp-support/mutation-listener.js $DST_REMOTE
    cp ../third_party/js/selenium/webdriver.json $DST_FF/webdriver_prefs.json
  '' + lib.optionalString stdenv.isDarwin ''
    mkdir -p $DST_PREFIX/common/macos
    cp ../common/manager/macos/selenium-manager $DST_PREFIX/common/macos
  '' + lib.optionalString stdenv.isLinux ''
    mkdir -p $DST_PREFIX/common/linux/
    cp ../common/manager/linux/selenium-manager $DST_PREFIX/common/linux/
  '';

  propagatedBuildInputs = [
    certifi
    trio
    trio-websocket
    urllib3
  ] ++ urllib3.optional-dependencies.socks;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-trio
  ];

  passthru.tests = {
    testing-vaultwarden = nixosTests.vaultwarden;
  };

  meta = with lib; {
    description = "Bindings for Selenium WebDriver";
    homepage = "https://selenium.dev/";
    license = licenses.asl20;
    maintainers = with maintainers; [ jraygauthier ];
  };
}
