# based on https://github.com/NixOS/nixpkgs/pull/311314

{ lib
, stdenv
, stdenvNoCC
, callPackage
, runCommand
, makeWrapper
, autoPatchelfHook
, patchelf
, fetchurl
, fetchFromGitHub
, makeDesktopItem
, copyDesktopItems
, imagemagick
, jdk
, jre
#, protobuf3_20
, grpc-java
, stripJavaArchivesHook
, tor
, findutils
, perl
, gradle2nix
# TODO? use fork https://github.com/haveno-dex/monero
, monero-cli

# javafx-graphics
, at-spi2-atk
, cairo
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libglvnd
, pango
, vivictpp
, xorg

# monero-java
, boost
, openssl
, libgcc
, hidapi
, protobuf
, libsodium
, unbound
, libusb1

# tor
, libz

, havenoFork ? "reto"
}:

let
  protobuf3_19 = callPackage (<nixpkgs> + "/pkgs/development/libraries/protobuf/generic-v3.nix") {
    version = "3.19.1";
    sha256 = "sha256-IQAlnpsO3AYfzXVnIHxLOKo1XzdWDmwwv+W/OanAl+s=";
  };
in

# fix: error: cannot find symbol: method parseUnknownField
# https://github.com/protocolbuffers/protobuf/issues/10695
# build.gradle: protobufVersion = '3.19.1'
#let protobuf = protobuf3_20; in
let protobuf = protobuf3_19; in

let
  versionSuffix = if havenoFork == null then "" else "-${havenoFork}";
in

gradle2nix.buildGradlePackage rec {
  pname = "haveno${versionSuffix}";
  version = "1.0.8";

  src = (
    if havenoFork == null then
    fetchFromGitHub {
      owner = "haveno-dex";
      repo = "haveno";
      rev = version;
      hash = "sha256-pNwlvdV8ilsbnI8VFghDYaZwk28ptKPV8+SArx2FOJQ=";
    }
    else
    if havenoFork == "reto" then
    fetchFromGitHub {
      owner = "retoaccess1";
      repo = "haveno-reto";
      rev = "v${version}";
      hash = "sha256-L9XH+LRnerPsRPmT3+G6rCSCXMUMVEh5NxpBVqon3BA=";
    }
    else
    throw "unknown version ${havenoFork}"
  );

  srcLogo = fetchurl {
    url = "https://github.com/haveno-dex/haveno-meta/raw/7a385ee238365ff1e2b6042dbe919d921ab5355b/logo/haveno_logo_icon.png";
    hash = "sha256-I1ZK9qBWtQRI72ODWL4ALRD37ywJp637QOanRy7rsts=";
  };

  lockFile = ./gradle.lock;

  /*
  https://github.com/milahu/nixpkgs/issues/67
  FIXME autoPatchelf: dont add workdir to rpath
  setting interpreter of native/linux/x64/tor.tar.xz/tor
  searching for dependencies of native/linux/x64/tor.tar.xz/tor
      libz.so.1 -> found: /nix/store/9nk7bsdlsmmnj96bivbvgqy491p65jdq-libz-1.2.8.2015.12.26-unstable-2018-03-31/lib
      libevent-2.1.so.7 -> found: /build/source/native/linux/x64/tor.tar.xz
      libssl.so.3 -> found: /build/source/native/linux/x64/tor.tar.xz
      libcrypto.so.3 -> found: /build/source/native/linux/x64/tor.tar.xz
  setting RPATH to: /nix/store/9nk7bsdlsmmnj96bivbvgqy491p65jdq-libz-1.2.8.2015.12.26-unstable-2018-03-31/lib:/build/source/native/linux/x64/tor.tar.xz
  */

  overrides = (
    let
      mkOverride = src: args: stdenvNoCC.mkDerivation ({
        name = src.name;
        nativeBuildInputs = [
          autoPatchelfHook
          #zip
          jdk
        ];
        dontAutoPatchelf = true;
        unpackPhase = ''
          ext=''${name##*.}
          runHook preUnpack
          sourceRoot=source
          mkdir $sourceRoot
          cd $sourceRoot
          libs=(${if (args.libs or []) == false then "" else lib.escapeShellArgs (args.libs or [])})
          doLibs=${if (args.libs or []) == false then "false" else "true"}
          bins=(${if (args.bins or []) == false then "" else lib.escapeShellArgs (args.bins or [])})
          archives=(${if (args.archives or []) == false then "" else lib.escapeShellArgs (args.archives or [])})
          doArchives=${if (args.archives or []) == false then "false" else "true"}
          archive_libs=()
          archive_bins=()
          if [ "$ext" = jar ]; then
            #echo name $name; echo src ${src}; echo src_nix ${src}; exit 1
            #unzip ${src}
            echo "unpacking ${src}"
            if $doLibs && [ ''${#libs[@]} == 0 ]; then
              while IFS= read -r lib; do
                libs+=("$lib")
              done < <(jar tf ${src} | grep '\.so$')
            fi
            if $doArchives && [ ''${#archives[@]} == 0 ]; then
              while IFS= read -r archive; do
                archives+=("$archive")
              # TODO more archive types
              done < <(jar tf ${src} | grep -E '\.(tar(\.(xz|gz|bz|bz2))?|zip)$')
            fi
            jar xf ${src} ''${libs[@]} ''${bins[@]} ''${archives[@]}
            idx=0
            for archive in ''${archives[@]}; do
              echo "unpacking $archive"
              archive_file="''${archive##*/}"
              archive_file="$TMP/temp_''${archive_file: -100}"
              mv "$archive" "$archive_file"
              archive_dir="$archive"
              mkdir "$archive_dir"
              # TODO more archive types
              # TODO generic unpack: zip, 7z, ...
              tar xf "$archive_file" -C "$archive_dir"
              rm "$archive_file"
              while IFS= read -r lib; do
                archive_libs+=("$lib")
              done < <(find "$archive_dir" -name '*.so*' -not -type d)
              while IFS= read -r bin; do
                archive_bins+=("$bin")
              done < <(find "$archive_dir" -executable -not -type d -not -name '*.so*')
            done
          elif [ "$ext" = exe ]; then
            cp ${src} $name
            chmod +w $name
          fi
          cd $NIX_BUILD_TOP
          runHook postUnpack
        '';
        buildPhase = ''
          runHook preBuild
          unpinLibs=$(
            for lib_out in ${lib.escapeShellArgs (args.unpinLibs or [])}; do
              #echo "lib_out $lib_out" >&2 # debug
              for lib in $lib_out/lib/*.so*; do
                # echo "lib_out lib $lib" >&2 # debug
                lib=''${lib##*/}
                lib=''${lib%.so*}.so
                echo "$lib"
              done
            done | sort -u
          )
          # echo unpinLibs: $unpinLibs # debug
          if [ "$ext" = jar ]; then
            # unpin libs
            echo "unpinning libs"
            for lib in "''${libs[@]}" "''${archive_libs[@]}"; do
              echo "$lib: unpinning"
              args=(patchelf)
              for dep in $(patchelf --print-needed $lib); do
                unp=''${dep%.so*}.so
                if echo "$unpinLibs" | grep -q -m1 -x -F "$unp"; then
                  args+=(--replace-needed "$dep" "$unp")
                  echo "$lib: unpinning $dep to $unp"
                fi
              done
              "''${args[@]}" "$lib"
            done
            autoPatchelf .
          elif [ "$ext" = exe ]; then
            chmod +x $name
            autoPatchelf $name
          fi
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          if [ "$ext" = jar ]; then
            cp ${src} $out
            chmod +w $out
            for archive in ''${archives[@]}; do
              echo "packing $archive"
              archive_dir="$archive"
              archive_file="$TMP/temp.tar"
              pushd "$archive_dir" >/dev/null
              case "$archive" in
                *.tar.gz|*.tar.xz|*.tar.bz|*.tar.bz2)
                  tar cf "$archive_file" .
                ;;
                *)
                  echo "FIXME internal error: unhandled archive type $archive"
                  exit 1
                ;;
              esac
              popd >/dev/null
              # dont use "tar cJf" as that is slooow
              # use minimal compression to make this fast
              case "$archive" in
                *.tar.gz) gzip -1 "$archive_file"; archive_file+=".gz";;
                *.tar.xz) xz -1 "$archive_file"; archive_file+=".xz";;
                *.tar.bz2) bzip2 -1 "$archive_file"; archive_file+=".bz2";;
                # TODO more archive types
                *)
                  echo "FIXME internal error: unhandled archive type $archive"
                  exit 1
                ;;
              esac
              stat "$archive_file" || true
              stat "$archive_dir" || true
              rm -rf "$archive_dir"
              # FIXME mv: cannot move '/build/temp.tar.xz' to 'native/linux/x64/tor.tar.xz': No such file or directory
              mv "$archive_file" "$archive"
            done
            jar uf $out ''${libs[@]} ''${bins[@]} ''${archives[@]}
          elif [ "$ext" = exe ]; then
            cp $name $out
          fi
          runHook postInstall
        '';
      } // (builtins.removeAttrs args [ "libs" "bins" "unpinLibs" "archives" ]));
    in
    {
      # fix: Execution failed for task ':proto:generateProto'.
      #   Cannot set /nix/store/.../protoc-gen-grpc-java-1.42.1-linux-x86_64.exe as executable
      "io.grpc:protoc-gen-grpc-java:1.42.1" = {
        "protoc-gen-grpc-java-1.42.1-linux-x86_64.exe" = src: mkOverride src { };
      };
      "org.openjfx:javafx-graphics:21.0.2" = {
        "javafx-graphics-21.0.2-linux.jar" = src: mkOverride src {
          buildInputs = [
            at-spi2-atk # libatk-1.0.so.0zulu17.out libatk-1.0.so
            cairo # libcairo-gobject.so.2 libcairo.so.2 libcairo-gobject.so libcairo.so
            fontconfig.lib # libfontconfig.so.1 libfontconfig.so
            freetype # libfreetype.so.6 libfreetype.so
            vivictpp # libfreetype.so.6 libfreetype.so
            gtk3 # libgdk-3.so.0 libgtk-3.so.0 libgdk-3.so libgtk-3.so
            gdk-pixbuf # libgdk_pixbuf-2.0.so.0 libgdk_pixbuf-2.0.so
            glib # libgio-2.0.so.0 libglib-2.0.so.0 libgobject-2.0.so.0 libgthread-2.0.so.0 libgio-2.0.so libglib-2.0.so libgobject-2.0.so libgthread-2.0.so
            libglvnd # libGL.so.1 libGL.so
            pango # libpango-1.0.so.0 libpangocairo-1.0.so.0 libpangoft2-1.0.so.0 libpango-1.0.so libpangocairo-1.0.so libpangoft2-1.0.so
            xorg.libX11 # libX11.so.6 libX11.so
            xorg.libXtst # libXtst.so.6 libXtst.so
            xorg.libXxf86vm # libXxf86vm.so.1 libXxf86vm.so
          ];
        };
      };
      "io.github.woodser:monero-java:0.8.31" = {
        "monero-java-0.8.31.jar" = src: mkOverride src {
          buildInputs = [
            boost # libboost_chrono.so libboost_filesystem.so libboost_program_options.so libboost_regex.so libboost_serialization.so libboost_thread.so
            openssl.out # libcrypto.so libssl.so
            libgcc.lib # libgcc_s.so.1 libgcc_s.so
            hidapi # libhidapi-libusb.so.0 libhidapi-libusb.so
            protobuf # libprotobuf.so
            libsodium # libsodium.so
            unbound.lib # libunbound.so.8 libunbound.so
            libusb1 # libusb-1.0.so.0 libusb-1.0.so
          ];
          unpinLibs = [
            boost # libboost_chrono.so libboost_filesystem.so libboost_program_options.so libboost_regex.so libboost_serialization.so libboost_thread.so
            protobuf # libprotobuf.so
            libsodium # libsodium.so
            openssl.out # libssl.so
          ];
        };
      };
      "com.github.haveno-dex.tor-binary:tor-binary-linux64:4e38c9d5cc22266fe06cc42578020bc0a50c783f" = {
        "tor-binary-linux64-4e38c9d5cc22266fe06cc42578020bc0a50c783f.jar" = src: mkOverride src {
          #archives = [ "native/linux/x64/tor.tar.xz" ];
          buildInputs = [
            libgcc.lib # libgcc_s.so.1 libgcc_s.so
            libz # libz.so.1 libz.so
          ];
        };
      };
    }
  );

  patches = [
    # fix: Execution failed for task ':desktop:installDist'.
    # > java.io.FileNotFoundException: /build/source/haveno-desktop.bat (No such file or directory)
    ./switch-platform-for-script-files.patch
  ];

  # disable "havenoDeps"
  # dont download monero from github
  # fix:  Execution failed for task ':core:havenoDeps'.
  #   java.net.UnknownHostException: github.com

  # TODO check if we need the haveno fork of monero
  # https://github.com/haveno-dex/monero

  # chmod -R +w
  # mkdir lib
  # fix: Execution failed for task ':relay:installDist'.
  #   Could not copy file '/build/source/relay/build/app/lib/checker-qual-3.33.0.jar' to '/build/source/lib/checker-qual-3.33.0.jar'.
  #   /build/source/lib/checker-qual-3.33.0.jar (Permission denied)
  # dst file exists and is read only
  # because it was copied from /nix/store
  # https://github.com/gradle/gradle/issues/1544

  # no. copy fails: Permission denied
  /*
      --replace-fail \
        "rootProject.projectDir" \
        "'$out'" \
  */

  postPatch = ''
    substituteInPlace build.gradle \
      --replace-fail \
        "processResources.dependsOn havenoDeps" \
        "// processResources.dependsOn havenoDeps" \
      --replace-fail \
        'build.dependsOn installDist' \
        '// build.dependsOn installDist' \
      --replace-fail \
        'artifact = "com.google.protobuf:protoc:' \
        'path = "${protobuf}/bin/protoc" //' \
      --replace-fail \
        'artifact = "io.grpc:protoc-gen-grpc-java:' \
        'path = "${grpc-java}/bin/protoc-gen-grpc-java" //' \

    perl -i -0777 -pe \
    's/((\n[ \t]*)copy {\n[ \t]*from [^\n]+\n[ \t]*into ([^\n]+)\n)/'\
    '$2exec {$2    commandLine "bash", "-c", '"'if [ -e \"\\\$1\" ]; then "\
    "chmod -R +w \"\\\$1\" || true; fi;'"', "--", $3$2}$1/g' build.gradle

    #grep -n "" build.gradle; exit 1 # debug

    mkdir core/src/main/resources/bin
    ln -s ${monero-cli}/bin/{monerod,monero-wallet-rpc} core/src/main/resources/bin
  '';

  # desktop/package/package.gradle
  # System.getenv("CI")
  CI = "1";

  gradleBuildFlags = [

    # fix: Dependency verification failed
    # because we modify files in overrides
    "--dependency-verification=off"

    #"--debug"

    # some tests fail, probably they need network access
    "--exclude-task=test"

    # FIXME Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0.
    # https://github.com/haveno-dex/haveno/issues/1117
    #"--warning-mode" "all"

    # based on Makefile
    "build"
  ];

  gradleInstallFlags = [
    # fix: Dependency verification failed
    # because we modify files in overrides
    "--dependency-verification=off"

    "installDist"
  ];

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    imagemagick # convert
    perl
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "Haveno${versionSuffix}";
      exec = "haveno-desktop";
      icon = "haveno";
      desktopName = "Haveno${versionSuffix} ${version}";
      genericName = "Decentralized Monero exchange";
      categories = [ "Network" "P2P" ];
    })
  ];

  preBuild = ''
    # based on Makefile
    mkdir .localnet
  '';

  # findutils: xargs for gradle wrapper scripts

  postInstall = ''
    cd $NIX_BUILD_TOP/$sourceRoot
    rm -rf p2p proto cli core relay monitor statsnode daemon apitest seednode inventory desktop
    mkdir -p $out/opt
    cp -r $NIX_BUILD_TOP/$sourceRoot $out/opt/haveno
    mkdir -p $out/bin
    for bin in $out/opt/haveno/haveno-*; do
      makeWrapper $bin $out/bin/''${bin##*/} \
        --set JAVA_HOME ${jre.home} \
        --prefix PATH ":" "${lib.makeBinPath [ findutils ]}" \

    done

    # deduplicate jar files
    cd $out/opt/haveno/lib
    mavenRepo=$(grep -m1 -F "repo.url 'file:/" $gradleInitScript | sed -E "s/^.*'file:(.*)'.*/\1/")
    find $mavenRepo -not -type d | while read f; do
      b=$(basename $f)
      if ! [ -e $b ]; then continue; fi
      rm $b
      ln -v -s $(readlink -f $f) $b
    done

    for size in 16 24 32 48 64 128; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      convert -resize "$size"x"$size" ${srcLogo} $out/share/icons/hicolor/"$size"x"$size"/apps/haveno.png
    done
  '';

  # passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = (
      "Decentralized Monero exchange" +
      (if havenoFork == null then "" else " [haveno-${havenoFork} fork]")
    );
    homepage = (
      if havenoFork == "reto" then
      "https://github.com/retoaccess1/haveno-reto"
      else
      "https://github.com/haveno-dex/haveno"
    );
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "haveno-desktop";
    platforms = platforms.all;
  };
}
