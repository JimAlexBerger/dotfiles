{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.programs.f5vpn;
  f5vpn =
    (
      pkgs.stdenv.mkDerivation {
        pname = "f5vpn";
        version = "7247.2024.0425.1";

        src = pkgs.fetchurl {
          url = "https://access.nrk.no/public/download/linux_f5vpn.x86_64.deb";
          hash = "sha256-FgqPDg4FigZvNvka802CG4jZGc51boZsA83+T2cLAQU=";
        };

        nativeBuildInputs = with pkgs; [ dpkg binutils libcap makeWrapper patchelf autoPatchelfHook qt6.wrapQtAppsHook ];
        buildInputs = with pkgs; [
          dbus
          fontconfig
          freetype
          glib
          glibc
          xorg.libICE
          bash
          xorg.libSM
          xorg.libX11
          xorg.libxcb
          xorg.libXcomposite
          xorg.libXcursor
          xorg.libXext
          xorg.libXi
          libglvnd
          libxkbcommon
          libxml2
          qt6.qtbase
          xorg.libXrender
          libxslt
          mesa
          sqlite
          zlib
        ];

        dontWrapQtApps = true;

        installPhase = ''
          mkdir -p $out/opt/f5/vpn
          cp -r opt/f5/vpn/* $out/opt/f5/vpn

          mkdir -p $out/bin
          ln -s $out/opt/f5/vpn/f5vpn $out/bin/f5vpn

          mkdir -p $out/share/applications
          ln -s $out/opt/f5/vpn/com.f5.f5vpn.desktop $out/share/applications/com.f5.f5vpn.desktop

          mkdir -p $out/share/dbus-1/services
          ln -s $out/opt/f5/vpn/com.f5.f5vpn.service $out/share/dbus-1/services/com.f5.f5vpn.service

          patchelf \
            --add-rpath $out/opt/f5/vpn/lib \
            --add-rpath $out/opt/f5/vpn/platforms \
            --add-needed libdbus-1.so \
            --add-needed libqxcb.so \
            --add-needed libXcursor.so \
            $out/opt/f5/vpn/f5vpn
        '';

        preFixup = ''
          wrapQtApp "$out/bin/f5vpn" --set QT_XKB_CONFIG_ROOT ${pkgs.xkeyboard_config}/share/X11/xkb
        '';

        postFixup = ''
          substituteInPlace $out/opt/f5/vpn/com.f5.f5vpn.service $out/opt/f5/vpn/com.f5.f5vpn.desktop --replace-fail "/opt/f5/vpn/f5vpn" $out/bin/f5vpn
          substituteInPlace $out/opt/f5/vpn/com.f5.f5vpn.desktop --replace-fail "DBusActivatable=true" "DBusActivatable=fail"
        '';
      }
    );
  f5epi =
    (
      pkgs.stdenv.mkDerivation {
        pname = "f5epi";
        version = "7250.2024.1008.1";

        src = pkgs.fetchurl {
          url = "https://access.nrk.no/public/download/linux_f5epi.x86_64.deb";
          hash = "sha256-PY9ZKLwcxQc/fWfqY2g+915nCN39bOE1njoC+sEqSN4=";
        };

        nativeBuildInputs = with pkgs; [
          binutils
          coreutils
          dpkg
          findutils
          gnupatch
          gnused
          makeWrapper
          patchelf
          autoPatchelfHook
          qt6.wrapQtAppsHook
          desktop-file-utils
        ];
        buildInputs = with pkgs; [
          xorg.libSM
          xorg.libX11
          xorg.libxcb
          xorg.libXcomposite
          xorg.libXcursor
          xorg.libXext
          xorg.libXi
          xorg.libICE
          xorg.libXrender
          bash
          dbus
          fontconfig
          freetype
          glib
          glibc
          libxkbcommon
          libxml2
          libxslt
          libglvnd
          qt6.qtbase
          mesa
          sqlite
          zlib
          xkeyboard_config
        ];

        dontWrapQtApps = true;

        installPhase = ''
          mkdir -p $out/opt/f5/epi
          cp -r opt/f5/epi/* $out/opt/f5/epi

          mkdir -p $out/bin
          ln -s $out/opt/f5/epi/f5epi $out/bin/f5epi

          mkdir -p $out/share/applications
          ln -s $out/opt/f5/epi/com.f5.f5epi.desktop $out/share/applications/com.f5.f5epi.desktop

          mkdir -p $out/share/dbus-1/services
          ln -s $out/opt/f5/epi/com.f5.f5epi.service $out/share/dbus-1/services/com.f5.f5epi.service

          patchelf \
            --add-rpath $out/opt/f5/epi/lib \
            --add-rpath $out/opt/f5/epi/platforms \
            --add-needed libdbus-1.so \
            --add-needed libqxcb.so \
            --add-needed libXcursor.so \
            $out/opt/f5/epi/f5epi
        '';

        preFixup = ''
          wrapQtApp "$out/bin/f5epi" --set QT_XKB_CONFIG_ROOT ${pkgs.xkeyboard_config}/share/X11/xkb
        '';

        postFixup = ''
          substituteInPlace $out/opt/f5/epi/com.f5.f5epi.service $out/opt/f5/epi/com.f5.f5epi.desktop --replace-fail "/opt/f5/epi/f5epi" $out/bin/f5epi
          substituteInPlace $out/opt/f5/epi/com.f5.f5epi.desktop --replace-fail "DBusActivatable=true" "DBusActivatable=fail"
        '';
      }
    );
  oesis =
    (
      pkgs.stdenv.mkDerivation {
        pname = "f5epi-oesis-inspector";
        version = "7090.2024.1101.1";

        src = pkgs.fetchurl {
          url = "https://access.nrk.no/public/download/linux_oesisInspector.tar";
          hash = "sha256-lcIr1iJaChCGeFkPxNUtM5mk5s6UCxa0ST8JErs0N68=";
        };

        nativeBuildInputs = with pkgs; [
          binutils
          coreutils
          findutils
          patchelf
          autoPatchelfHook
        ];
        buildInputs = with pkgs; [
          glibc
          gcc-unwrapped
        ];

        dontUnpack = true;

        installPhase = ''
          mkdir -p result
          tar xf $src -C result

          mkdir -p $out
          cp result/OesisInspector_x86_64.so $out
          cp result/OesisInspector4_x86_64.so $out
            
          mkdir -p $out/lib64
          cp -r result/lib64/* $out/lib64

          echo -n $version >> $out/OesisInspector.ver

          patchelf --add-rpath $out/lib64 $out/OesisInspector_x86_64.so
          patchelf --add-rpath $out/lib64 $out/OesisInspector4_x86_64.so
        '';
      }
    );
in
{
  options.programs.f5vpn = {
    enable = lib.mkEnableOption "Enable f5vpn";
    oesisUser = lib.mkOption
      {
        type = lib.types.str;
        description = "The user wich will have the oesis installed.";
      };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ f5vpn f5epi oesis ];

    services.dbus.packages = [ f5vpn f5epi ];

    security.wrappers = {
      svpn = {
        source = "${f5vpn}/opt/f5/vpn/svpn";
        owner = "root";
        group = "root";
        setuid = true;
      };

      f5vpn = {
        source = "${f5vpn}/bin/f5vpn";
        owner = "root";
        group = "root";
        capabilities = "cap_kill+ep";
      };
    };

    systemd.tmpfiles.rules = [
      "d /opt/f5/vpn 0755 root root -"
      "L+ /opt/f5/vpn/svpn - - - - /run/wrappers/bin/svpn"
      "L+ /opt/f5/vpn/f5vpn - - - - /run/wrappers/bin/f5vpn"
      "L+ /opt/f5/vpn/tunnelserver - - - - ${f5vpn}/opt/f5/vpn/tunnelserver"

      "d /opt/f5/epi 0755 root root -"
      "L+ /opt/f5/epi/f5epi - - - - ${f5epi}/opt/f5/epi/f5epi"
      "L+ /opt/f5/epi/f5PolicyServer - - - - ${f5epi}/opt/f5/epi/f5PolicyServer"

      "d /home/${cfg.oesisUser}/.F5Networks 0755 ${cfg.oesisUser} users -"
      "L+ /home/${cfg.oesisUser}/.F5Networks/Inspectors - - - - ${oesis}"
    ];

  };
}
