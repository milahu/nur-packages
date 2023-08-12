{ pkgs ? import ./nix { }, lib ? pkgs.lib }:
let
  v1_internal = pkgs.callPackage ./internal-v1.nix { };
  v2_internal = pkgs.callPackage ./internal-v2.nix { };
  separatePublicAndInternalAPI = api: extraAttributes: {
    inherit (api) shell build node_modules;

    # *** WARNING ****
    # using any of the functions exposed by `internal` is not supported. That
    # being said, hiding them would only lead to copy&paste and it is also useful
    # for testing internal building blocks.
    internal = lib.warn "[npmlock2nix] You are using the unsupported internal API." (
      api
    );
  } // (lib.listToAttrs (map (name: lib.nameValuePair name api.${name}) extraAttributes));
  v1 = separatePublicAndInternalAPI v1_internal [ ];
  v2 = separatePublicAndInternalAPI v2_internal [ "packageRequirePatchShebangs" ];
in
{
  inherit v1;
  inherit v2;
  tests = pkgs.callPackage ./tests { };
} // (lib.mapAttrs
  (lib.warn "[npmlock2nix] You are using the unversion prefix for builders. This is fine for now. In the future we will move to a versioned interface (old versions remain as they are). The currently used functions are availabe as `npmlock2nix.v1` for example `npmlock2nix.v1.build`.")
  v1)
