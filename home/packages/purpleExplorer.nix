pkgs:

pkgs.stdenv.mkDerivation {
  pname = "PurpleExplorer";
  version = "0.1.17";

  src = pkgs.fetchzip {
    url = "https://github.com/telstrapurple/PurpleExplorer/releases/download/0.1.17/PurpleExplorer_linux-x64.zip";
    hash = "sha256-mu4w7ZdOJivyod4rrPyfj617j3GeRSp7eZZL93SGkAI=";
    stripRoot = false;
  };

  buildInputs = with pkgs; [
    dotnetCorePackages.sdk_6_0
  ];

  installPhase = ''
    mkdir -p $out/libs
    cp -R . $out/libs

    mkdir -p $out/bin
    ln -s $out/libs/PurpleExplorer $out/bin/PurpleExplorer 
  '';
}
