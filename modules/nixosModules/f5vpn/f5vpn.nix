{ lib, config, pkgs, ... }:
with lib;
let
  f5vpn =
    (
      pkgs.stdenv.mkDerivation {
        pname = "f5vpn";
        version = "7247.2024.0425.1";

        src = pkgs.fetchurl {
          url = "https://access.nrk.no/public/download/linux_f5vpn.x86_64.deb";
          hash = "sha256-0GHWo9T8QfRJx1zn0kzJx0C28wWWD1nmU8bFb8iB4/E=";
        };

        nativeBuildInputs = with pkgs; [ dpkg binutils libcap patchelf ];
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
          libxkbcommon
          libxml2
          xorg.libXrender
          libxslt
          mesa
          sqlite
          zlib
        ];

        installPhase = ''
          mkdir -p $out/opt/f5/vpn
          cp -r opt/f5/vpn/* $out/opt/f5/vpn

          mkdir -p $out/bin
          ln -s $out/opt/f5/vpn/f5vpn $out/bin/f5vpn

          mkdir -p $out/share/applications
          ln -s $out/opt/f5/vpn/com.f5.f5vpn.desktop $out/share/applications/com.f5.f5vpn.desktop

          mkdir -p $out/share/dbus-1/services
          ln -s $out/opt/f5/vpn/com.f5.f5vpn.service $out/share/dbus-1/services/com.f5.f5vpn.service

          patchelf --add-rpath $out/opt/f5/vpn/lib $out/opt/f5/vpn/f5vpn
          patchelf --add-rpath $out/opt/f5/vpn/platforms $out/opt/f5/vpn/f5vpn
        '';

        postFixup = ''
          substituteInPlace $out/opt/f5/vpn/com.f5.f5vpn.service $out/opt/f5/vpn/com.f5.f5vpn.desktop --replace-fail "/opt/f5/vpn/f5vpn" $out/bin/f5vpn
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
          mesa
          sqlite
          zlib
          xkeyboard_config
        ];

        installPhase = ''
          mkdir -p $out/opt/f5/epi
          cp -r opt/f5/epi/* $out/opt/f5/epi

          mkdir -p $out/bin
          ln -s $out/opt/f5/epi/f5epi $out/bin/f5epi

          mkdir -p $out/share/applications
          ln -s $out/opt/f5/epi/com.f5.f5epi.desktop $out/share/applications/com.f5.f5epi.desktop

          mkdir -p $out/share/dbus-1/services
          ln -s $out/opt/f5/epi/com.f5.f5epi.service $out/share/dbus-1/services/com.f5.f5epi.service

          patchelf --add-rpath $out/opt/f5/epi/lib $out/opt/f5/epi/f5epi
          patchelf --add-rpath $out/opt/f5/epi/platforms $out/opt/f5/epi/f5epi
        '';

        postFixup = ''
          substituteInPlace $out/opt/f5/epi/com.f5.f5epi.service $out/opt/f5/epi/com.f5.f5epi.desktop --replace-fail "/opt/f5/epi/f5epi" $out/bin/f5epi
        '';
      }
    );
  oesis =
    (
      pkgs.stdenv.mkDerivation {
        pname = "f5epi-oesis-inspector";
        version = "7090.2024.0807.1";

        src = pkgs.fetchurl {
          url = "https://access.nrk.no/public/download/linux_oesisInspector.tar";
          hash = "sha256-lcIr1iJaChCGeFkPxNUtM5mk5s6UCxa0ST8JErs0N68=";
        };

        nativeBuildInputs = with pkgs; [
          binutils
          coreutils
          findutils
          patchelf
        ];
        buildInputs = with pkgs; [
          glibc
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
      }
      };

    config = mkIf cfg.enable {

      environment.systemPackages = [ f5vpn f5epi oesis ]

        security.wrappers = {
      svpn = {
      source = "${f5vpn}/opt/f5/vpn/svpn";
      owner = "root";
      group = "root";
      setuid = true;
    };
    f5vpn = {
      source = "${f5vpn}/opt/f5/vpn/f5vpn";
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

    "d /home/${cfg.oesisUser}/.F5Networks/Inspectors"
    "L+ /home/${cfg.oesisUser}/.F5Networks/Inspectors - - - - ${oesis}"
  ];

};
}
