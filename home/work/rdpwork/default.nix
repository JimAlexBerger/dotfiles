{ config, pkgs, ... }:
let
  rdpwork =
    pkgs.writeShellApplication {
      name = "rdpwork";
      runtimeInputs = with pkgs; [ bat fzf uutils-coreutils uutils-findutils freerdp3 ];
      text = ''
        bat ${config.sops.secrets.rdpservers.path} | fzf --with-nth '{1}' --delimiter , | cut -d , -f 2 | xargs -I{} xfreerdp /u:tmp651227 /d:felles /cert:tofu /v:{}
      '';
  };
in
{
  home.packages = [
    rdpwork
  ];

  sops.secrets.rdpservers = {
    format = "binary";
    sopsFile = ../../../secrets/rdpservers/rdpservers;
  };
}
