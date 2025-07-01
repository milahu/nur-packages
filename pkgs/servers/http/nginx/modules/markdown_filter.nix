{
  lib,
  fetchFromGitHub,
  cmark-gfm,
  stdenv,
}:

rec {
  name = "ngx_markdown_filter_module";
  src-unpatched = fetchFromGitHub {
    owner = "ukarim";
    repo = "ngx_markdown_filter_module";
    # rev = "0.1.3";
    # https://github.com/ukarim/ngx_markdown_filter_module/pull/6
    rev = "11eef87a7966a72cbd10da1f80472b8b3a24c198";
    hash = "sha256-Ap22bM2HZ/F0WjkdQSPF4XcowxclE2b45jaL5MvNF1A=";
  };
  src = stdenv.mkDerivation {
    name = "source";
    src = src-unpatched;
    postPatch = ''
      mv config_gfm config
    '';
    installPhase = ''
      cp -r . $out
    '';
  };
  # TODO make nginx/generic.nix use buildInputs
  # buildInputs = [
  # nixpkgs/pkgs/servers/http/nginx/generic.nix
  # buildInputs = [ ... ] ++ mapModules "inputs"
  # FIXME ngx_markdown_filter_module.c:10:14: fatal error: cmark.h: No such file or directory
  inputs = [
    cmark-gfm
  ];
  # TODO make nginx/generic.nix use postPatch
  # no. postPatch is not used
  /*
  postPatch = ''
    mv config_gfm config
  '';
  */
  # configureFlags is not used by pkgs.nginx
  # error: ngx_markdown_filter_module.c:10:14: fatal error: cmark.h: No such file or directory
  # fix: use patched nginx in pkgs.nur.repos.milahu.nginx
  configureFlags = [ "--with-cc-opt=-DWITH_CMARK_GFM=1" ];
  meta = with lib; {
    description = "Markdown-to-html nginx module";
    homepage = "https://github.com/ukarim/ngx_markdown_filter_module";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ];
  };
}
