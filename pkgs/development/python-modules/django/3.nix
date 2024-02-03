{ lib
, stdenv
, buildPythonPackage
, fetchPypi
, fetchurl
, substituteAll
, geos_3_9
, gdal
, asgiref
, pytz
, sqlparse
, tzdata
, pythonOlder
, withGdal ? false
}:

buildPythonPackage rec {
  pname = "django";
  version = "3.2.23";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    pname = "Django";
    inherit version;
    hash = "sha256-gpaPNkDinvSnc68sKESPX3oI0AHGrAWzLQKu7mUJUIs=";
  };

  patches = [
    (substituteAll {
      src = ./django_3_set_zoneinfo_dir.patch;
      zoneinfo = tzdata + "/share/zoneinfo";
    })
    # https://github.com/django/django/pull/17815
    # fix: django.db.utils.OperationalError: no such column: django_migrations.id
    (fetchurl {
      url = "https://github.com/milahu/django/commit/d765cd349e6371a2d1e3277e1b8db550776a681b.patch";
      hash = "sha256-oad4HKiKKAe5By0En2W7TCH6e/wt7roMlOhBUXOKFy4=";
    })
  ] ++ lib.optional withGdal
    (substituteAll {
      src = ./django_3_set_geos_gdal_lib.patch;
      inherit geos_3_9;
      inherit gdal;
      extension = stdenv.hostPlatform.extensions.sharedLibrary;
    });

  propagatedBuildInputs = [
    asgiref
    pytz
    sqlparse
  ];

  # too complicated to setup
  doCheck = false;

  pythonImportsCheck = [ "django" ];

  meta = with lib; {
    description = "A high-level Python Web framework";
    homepage = "https://www.djangoproject.com/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ georgewhewell ];
  };
}
