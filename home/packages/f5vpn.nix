{ pkgs, ... }:
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
in
{
  home.packages =
    [
      f5vpn
    ];
}
