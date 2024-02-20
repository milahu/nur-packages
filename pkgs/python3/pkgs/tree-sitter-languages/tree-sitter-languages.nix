# FIXME use parser binaries from tree-sitter-grammars
# compiling all grammars into one binary is a waste of build time

{ lib
, python3
, fetchFromGitHub
, tree-sitter-grammars
}:

/*
# debug: build faster
let old-tree-sitter-grammars = tree-sitter-grammars; in
let
  tree-sitter-grammars = {
    tree-sitter-html = old-tree-sitter-grammars.tree-sitter-html;
  };
in
*/

# update grammars to fix build errors: multiple definition of ...
# helper functions must be declared as "static"
# see also
# https://github.com/tree-sitter/tree-sitter-html/pull/64
# https://github.com/grantjenks/py-tree-sitter-languages/issues/55
let old-tree-sitter-grammars = tree-sitter-grammars; in
let
  tree-sitter-grammars = old-tree-sitter-grammars // {
    # https://github.com/Himujjal/tree-sitter-svelte/issues/56
    tree-sitter-svelte = null;
    # https://github.com/ikatyang/tree-sitter-vue/issues/27
    tree-sitter-vue = null;
    tree-sitter-rst = old-tree-sitter-grammars.tree-sitter-rst.overrideAttrs (oldAttrs: {
      src = fetchFromGitHub {
        owner = "stsewd";
        repo = "tree-sitter-rst";
        rev = "3ba9eb9b5a47aadb1f2356a3cab0dd3d2bd00b4b";
        hash = "sha256-0w11mtDcIc2ol9Alg4ukV33OzXADOeJDx+3uxV1hGfs=";
      };
    });
  };
in

python3.pkgs.buildPythonPackage rec {
  pname = "tree-sitter-languages";
  version = "1.10.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "grantjenks";
    repo = "py-tree-sitter-languages";
    rev = "v${version}";
    hash = "sha256-AuPK15xtLiQx6N2OATVJFecsL8k3pOagrWu1GascbwM=";
  };

  buildInputs = [
    python3.pkgs.cython
  ];

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    python3.pkgs.tree-sitter
  ];

  postUnpack = ''
    cd $sourceRoot
    mkdir vendor
    ${
      builtins.concatStringsSep "" (
        builtins.attrValues (
          builtins.mapAttrs
          (n: p:
            "ln -v -s ${p.src.outPath} vendor/${n}\n"
          )
          (lib.filterAttrs (k: v: v ? src) tree-sitter-grammars)
        )
      )
    }
    cd ..
  '';

  postBuild = ''
    echo creating $out/${python3.sitePackages}/tree_sitter_languages/languages.so

    repo_paths=(
    ${
      builtins.concatStringsSep "" (
        builtins.attrValues (
          builtins.mapAttrs
          (n: p:
            "  'vendor/${n}'\n"
          )
          (lib.filterAttrs (k: v: v ? src) tree-sitter-grammars)
        )
      )
    }
    )
    # get actual repo paths
    # fix: No such file or directory: 'vendor/tree-sitter-markdown/src/parser.c
    for idx in ''${!repo_paths[@]}; do
      dir=''${repo_paths[$idx]}
      [ -e $dir/src/parser.c ] && continue
      parser=$(find $dir -path '*/src/parser.c')
      dir=''${parser%/src/parser.c}
      repo_paths[$idx]=$dir
    done

    #mkdir -p $out/${python3.sitePackages}/tree_sitter_languages
    build_py=$(
      echo "import tree_sitter"
      echo "repo_paths = ["
      for dir in ''${repo_paths[@]}; do
        echo "  '$dir',"
      done
      echo "]"
      echo "output_path = '$out/${python3.sitePackages}/tree_sitter_languages/languages.so'"
      echo "tree_sitter.Language.build_library(output_path, repo_paths)"
    )
    echo "$build_py" | grep -n "" # debug
    python3 -c "$build_py"
  '';

  pythonImportsCheck = [ "tree_sitter_languages" ];

  meta = with lib; {
    description = "Python module with all tree-sitter languages";
    homepage = "https://github.com/grantjenks/py-tree-sitter-languages";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
