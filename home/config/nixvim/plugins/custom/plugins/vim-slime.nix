{
  programs.nixvim = {
    plugins.vim-slime = {
      enable = true;
      settings = {
        target = "tmux";
        default_config = {
          socket_name = "default";
          target_pane = "{last}";
        };
      };
    };
  };
}
