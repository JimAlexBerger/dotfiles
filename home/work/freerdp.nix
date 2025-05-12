{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    freerdp3
  ];

  sops.secrets.rdpservers = {
    format = "binary";
    sopsFile = ../../secrets/rdpservers/rdpservers;
  };

  programs.zsh.shellAliases.rdpwork = "cat ${config.sops.secrets.rdpservers.path} | ${pkgs.fzf}/bin/fzf --with-nth '{1}' --delimiter , | cut -d , -f 2 | xargs -I{} xfreerdp /u:tmp651227 /d:felles /cert:tofu /v:{}";
}
